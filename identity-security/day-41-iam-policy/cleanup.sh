#!/bin/bash
# Cleanup script for IAM policy test resources

PROJECT_ID=$(gcloud config get-value project)
BUCKET_NAME="logs-bucket-${PROJECT_ID}"
SERVICE_ACCOUNT_NAME="log-analyzer-sa"
SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"


gcloud storage rm "gs://${BUCKET_NAME}" --recursive
# Delete the service account
echo "Deleting service account..."
gcloud iam service-accounts delete "${SERVICE_ACCOUNT_EMAIL}" --quiet

echo "Cleanup complete!"
