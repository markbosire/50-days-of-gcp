#!/bin/bash

# Variables
PROJECT_ID=$(gcloud config get-value project)
SERVICE_ACCOUNT_NAME="api-tester-sa"
KEY_FILE="${SERVICE_ACCOUNT_NAME}-key.json"
SCOPE="https://www.googleapis.com/auth/compute.readonly"

# Create Service Account
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
    --display-name "API Tester Service Account"

# Create Key for the Service Account
gcloud iam service-accounts keys create $KEY_FILE \
    --iam-account=${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com

# Assign the predefined role (roles/compute.viewer) to the Service Account
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com \
    --role=roles/compute.viewer

curl -o jwt.sh https://raw.githubusercontent.com/markbosire/100-days-of-gcp/refs/heads/main/identity-security/day-42-service-accounts/jwt.sh


# Get an access token using the service account key
ACCESS_TOKEN=$(bash jwt.sh $KEY_FILE $SCOPE)
echo $ACCESS_TOKEN
# Test API without the key
echo "Testing API without the key:"
curl -s -X GET "https://compute.googleapis.com/compute/v1/projects/$PROJECT_ID/zones" || echo "Access denied"

# Test API with the key
echo "\nTesting API with the key:"
 curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
        -X GET "https://compute.googleapis.com/compute/v1/projects/$PROJECT_ID/zones" | \
        jq -r '.items[].name' || echo "Access denied"
