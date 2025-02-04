#!/bin/bash
PROJECT_ID=$(gcloud config get-value project)
SERVICE_ACCOUNT_NAME="api-tester-sa"
KEY_FILE="${SERVICE_ACCOUNT_NAME}-key.json"
# Task 1: Delete the Service Account
# This command deletes the service account named "api-tester-sa".
gcloud iam service-accounts delete ${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com --quiet

# Task 2: Remove the Key File
# This deletes the private key file "api-tester-sa-key.json" if it exists.
rm -f ${KEY_FILE}

# Task 3: Remove the JWT Script
# This deletes the downloaded "jwt.sh" script if it exists.
rm -f jwt.sh

# Task 4: Unset the Access Token Variable
# This clears the ACCESS_TOKEN environment variable.
unset ACCESS_TOKEN

echo "Cleanup completed successfully."
