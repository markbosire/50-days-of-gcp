#!/bin/bash

# Set variables
PROJECT_ID=$(gcloud config get-value project)
BUCKET_NAME="${PROJECT_ID}-retention-demo"

# Check if bucket exists
echo "Checking for bucket: $BUCKET_NAME"
if gcloud storage buckets describe gs://$BUCKET_NAME &>/dev/null; then
    echo "Found bucket: $BUCKET_NAME"
    
    # List all objects in the bucket
    echo "Listing objects in bucket..."
    gcloud storage ls gs://$BUCKET_NAME
    
    # Remove all objects in the bucket
    echo "Removing all objects..."
    gcloud storage rm -r gs://$BUCKET_NAME/* 2>/dev/null || echo "No objects to delete or objects still under retention"
    
    # Try to delete the bucket
    echo "Attempting to delete bucket..."
    gcloud storage buckets delete gs://$BUCKET_NAME --quiet || echo "Failed to delete bucket. It might still have objects under retention."
else
    echo "Bucket $BUCKET_NAME not found"
fi

echo "Cleanup script completed"
