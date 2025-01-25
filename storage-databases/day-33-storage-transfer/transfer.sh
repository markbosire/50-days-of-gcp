#!/bin/bash

# Set project number and bucket name
PROJECT_NUMBER=$(gcloud projects describe $(gcloud config get-value project) --format="value(projectNumber)")
BUCKET_NAME="test-storage-bucket-$PROJECT_NUMBER"
JOB_NAME="test-storage-job-$PROJECT_NUMBER"
SOURCE_BUCKET="s3://power-datastore/"
PREFIX="v9/daily/2025/01/"

# Step 1: Create a Google Cloud Storage bucket (ignore errors if it already exists)
echo "Creating Google Cloud Storage bucket..."
gcloud storage buckets create gs://$BUCKET_NAME --location=US || echo "Bucket already exists."

# Step 2: Enable the Storage Transfer API
echo "Enabling Storage Transfer API..."
gcloud services enable storagetransfer.googleapis.com

# Step 3: Grant necessary permissions to the Storage Transfer Service account
echo "Granting necessary permissions to the Storage Transfer Service account..."
gcloud storage buckets add-iam-policy-binding gs://$BUCKET_NAME \
 --member=serviceAccount:project-$PROJECT_NUMBER@storage-transfer-service.iam.gserviceaccount.com \
 --role=roles/storage.admin

# Step 4: Create a transfer job to copy the specified data from S3 to Google Cloud Storage
echo "Creating transfer job to copy data from S3 to Google Cloud Storage..."
gcloud transfer jobs create $SOURCE_BUCKET gs://$BUCKET_NAME \
  --include-prefixes="$PREFIX" \
  --name=$JOB_NAME

# Step 5: Wait for a short time before verifying object metadata
echo "Waiting for the transfer job to start processing..."
sleep 60  # Adjust the duration as needed based on expected data transfer time

# Verify object metadata with gcloud
echo "Verifying transferred object metadata..."
gcloud storage ls --recursive gs://$BUCKET_NAME/

echo "Transfer job started. Check the Google Cloud Console for progress and completion."

