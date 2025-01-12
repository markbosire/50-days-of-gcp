#!/bin/bash

# Script to create a GCS bucket, generate signed URLs, and test their functionality using only `gcloud`.

# Variables
PROJECT_ID=$(gcloud config get-value project)         
BUCKET_NAME="secure-test-$PROJECT_ID"     
OBJECT_NAME="test-file.txt"               
SERVICE_ACCOUNT="test-signed-url-sa"    
VM_INSTANCE="test-instance"             
ZONE="us-central1-a"                    
EXPIRATION_SHORT=30s                    
# Create a GCS bucket using `gcloud`
echo "Creating GCS bucket: $BUCKET_NAME..."
gcloud storage buckets create "gs://$BUCKET_NAME" --project="$PROJECT_ID"

# Upload a test file to the bucket using `gcloud`
echo "Uploading test file: $OBJECT_NAME..."
echo "This is a test file." > "$OBJECT_NAME"
gcloud storage cp "$OBJECT_NAME" "gs://$BUCKET_NAME/$OBJECT_NAME"

# Create a service account
echo "Creating service account: $SERVICE_ACCOUNT..."
gcloud iam service-accounts create "$SERVICE_ACCOUNT" \
    --description="Service account for testing signed URLs" \
    --display-name="Signed URL Test SA"

# Grant the service account access to the bucket
echo "Granting permissions to the service account..."
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.objectViewer"


# Generate a signed URL using `gcloud storage sign-url`
echo "Generating signed URL with short expiration ($EXPIRATION_SHORT seconds)..."
 
SIGNED_URL=$(gcloud storage sign-url "gs://$BUCKET_NAME/$OBJECT_NAME" \
    --duration="$EXPIRATION_SHORT" \
    --private-key-file=<(gcloud iam service-accounts keys create - --iam-account="$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com") \
    --format="value(signed_url)")

echo "Signed URL: $SIGNED_URL"

# Test the signed URL from the local machine (should fail)
echo "Testing signed URL from local machine (should fail)..."
curl -s "$SIGNED_URL"

# Wait for the signed URL to expire
echo "Waiting for the signed URL to expire ($EXPIRATION_SHORT seconds)..."
sleep "$EXPIRATION_SHORT"

# Test the signed URL again after expiration (should fail)
echo "Testing signed URL after expiration (should fail)..."
curl -s "$SIGNED_URL"

# Clean up resources
#echo "Cleaning up resources..."
#gcloud iam service-accounts delete "$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com" --quiet
#gcloud storage rm -r "gs://$BUCKET_NAME" --quiet
#rm -f "$OBJECT_NAME"

echo "Script completed."
