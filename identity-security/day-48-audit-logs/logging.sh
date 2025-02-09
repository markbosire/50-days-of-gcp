#!/bin/bash

# Set your project ID
PROJECT_ID=$(gcloud config get-value project) 
# Enable Audit Logs for IAM
echo "Enabling Cloud Audit Logs for IAM..."
gcloud services enable logging.googleapis.com

# Generate IAM activity - Add a role to a user (Replace USER_EMAIL)
USER_EMAIL="$(gcloud config get-value account)"
ROLE="roles/iap.tunnelResourceAccessor"

echo "Granting $ROLE to $USER_EMAIL..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="user:$USER_EMAIL" --role="$ROLE"

# Wait for logs to be generated
echo "Waiting for logs to be generated..."
sleep 20

# Query Cloud Audit Logs for IAM activities
echo "Fetching IAM Audit Logs..."
gcloud logging read "resource.type=gcp_project AND protoPayload.serviceName=iam.googleapis.com" \
    --format=json | jq '.[] | {timestamp: .timestamp, method: .protoPayload.methodName, principalEmail: .protoPayload.authenticationInfo.principalEmail}'

# Cleanup - Remove the role
echo "Removing the IAM role from $USER_EMAIL..."
gcloud projects remove-iam-policy-binding $PROJECT_ID \
    --member="user:$USER_EMAIL" --role="$ROLE"

echo "Script execution complete!"

