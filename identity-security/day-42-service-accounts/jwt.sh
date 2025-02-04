#!/bin/bash

# Check if the required arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <path_to_service_account_key.json> <scope>"
    exit 1
fi

SERVICE_ACCOUNT_KEY_PATH=$1
SCOPE=$2

# Extract the service account email from the JSON key file
SERVICE_ACCOUNT_EMAIL=$(jq -r '.client_email' $SERVICE_ACCOUNT_KEY_PATH)

# Extract the private key from the JSON key file and save it to a temporary file
PRIVATE_KEY=$(jq -r '.private_key' $SERVICE_ACCOUNT_KEY_PATH)
TEMP_KEY_FILE=$(mktemp)
echo -n "$PRIVATE_KEY" > $TEMP_KEY_FILE

# Current time in seconds since 1970-01-01 00:00:00 UTC
NOW=$(date +%s)

# JWT expiration time (1 hour from now)
EXP=$(($NOW + 3600))

# JWT Header
HEADER=$(echo -n '{"alg":"RS256","typ":"JWT"}' | base64 | tr -d '\n' | tr -d '=' | tr '/+' '_-')

# JWT Claim Set
CLAIM_SET=$(echo -n "{
  \"iss\": \"$SERVICE_ACCOUNT_EMAIL\",
  \"scope\": \"$SCOPE\",
  \"aud\": \"https://oauth2.googleapis.com/token\",
  \"exp\": $EXP,
  \"iat\": $NOW
}" | base64 | tr -d '\n' | tr -d '=' | tr '/+' '_-')

# JWT Signature
SIGNATURE=$(echo -n "$HEADER.$CLAIM_SET" | openssl dgst -sha256 -sign $TEMP_KEY_FILE | base64 | tr -d '\n' | tr -d '=' | tr '/+' '_-')

# JWT
JWT="$HEADER.$CLAIM_SET.$SIGNATURE"

# Clean up the temporary private key file
rm -f $TEMP_KEY_FILE

# Request Access Token
RESPONSE=$(curl -s -X POST \
  -d "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=$JWT" \
  https://oauth2.googleapis.com/token)

# Extract Access Token from the response
ACCESS_TOKEN=$(echo $RESPONSE | jq -r '.access_token')

# Output the Access Token
if [ -n "$ACCESS_TOKEN" ]; then
    echo "$ACCESS_TOKEN"
else
    echo "Failed to retrieve access token. Response: $RESPONSE"
fi
