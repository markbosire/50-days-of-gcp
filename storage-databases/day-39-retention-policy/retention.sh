#!/bin/bash

# Set variables
PROJECT_ID=$(gcloud config get-value project)
BUCKET_NAME="${PROJECT_ID}-retention-demo"
RETENTION_PERIOD="60s"  # 60 seconds retention for demonstration
LOCATION="us-central1"

# Create a new bucket with uniform bucket-level access
echo "Creating new bucket: $BUCKET_NAME"
gcloud storage buckets create gs://$BUCKET_NAME \
    --project=$PROJECT_ID \
    --location=$LOCATION \
    --uniform-bucket-level-access

# Set retention policy
echo "Setting retention policy for $RETENTION_PERIOD"
gcloud storage buckets update gs://$BUCKET_NAME \
    --retention-period=$RETENTION_PERIOD

# Upload a test file
echo "Hello World!" > test_file.txt
echo "Uploading test file..."
gcloud storage cp test_file.txt gs://$BUCKET_NAME/

# First delete attempt (should fail)
echo "First delete attempt..."
gcloud storage rm gs://$BUCKET_NAME/test_file.txt

# Wait for retention period to expire
echo "Waiting for retention period to expire..."
sleep 65  # Wait 65 seconds (slightly longer than retention period)

# Second delete attempt (should succeed)
echo "Second delete attempt..."
gcloud storage rm gs://$BUCKET_NAME/test_file.txt



echo "Script completed"
