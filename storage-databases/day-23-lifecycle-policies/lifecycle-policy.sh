#!/bin/bash

# Get the current project ID
PROJECT_ID=$(gcloud config get-value project)

# Variables
BUCKET_NAME="${PROJECT_ID}-photos-bucket"  # Prefix the bucket name with the project ID
LIFECYCLE_FILE="lifecycle.json"

# Create the bucket (if it doesn't exist)
echo "Creating bucket: gs://$BUCKET_NAME"
gcloud storage buckets create gs://$BUCKET_NAME

# Create the lifecycle JSON file
cat <<EOF > $LIFECYCLE_FILE
{
  "rule": [
    {
      "action": {
        "type": "SetStorageClass",
        "storageClass": "NEARLINE"
      },
      "condition": {
        "age": 30,
        "matchesStorageClass": ["STANDARD"]
      }
    },
    {
      "action": {
        "type": "Delete"
      },
      "condition": {
        "age": 365
      }
    }
  ]
}
EOF

# Apply the lifecycle rules to the bucket
echo "Applying lifecycle policy to gs://$BUCKET_NAME"
gcloud storage buckets update gs://$BUCKET_NAME --lifecycle-file=$LIFECYCLE_FILE

# Verify the lifecycle rules
echo "Verifying lifecycle policy for gs://$BUCKET_NAME"
gcloud storage buckets describe gs://$BUCKET_NAME --format="json(lifecycle_config)"

echo "Lifecycle policy applied successfully to gs://$BUCKET_NAME"
