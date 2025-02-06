#!/bin/bash

# Set your project ID
PROJECT_ID=$(gcloud config get-value project)
SOURCE_ROLE="roles/storage.objectViewer"
NEW_ROLE_ID="storage_viewer_creator"
ROLE_TITLE="Custom Storage Object Viewer with Create"
ROLE_DESCRIPTION="Same as Storage Object Viewer but with create permission"

# Copy the existing Storage Object Viewer role
gcloud iam roles copy \
  --source "$SOURCE_ROLE" \
  --destination "$NEW_ROLE_ID" \
  --dest-project "$PROJECT_ID" \
  --quiet

# Update the copied role to add storage.objects.create permission
gcloud iam roles update "$NEW_ROLE_ID" \
  --project "$PROJECT_ID" \
  --add-permissions="storage.objects.create" 

# Describe the final role policy
echo "Final role policy for '$NEW_ROLE_ID':"
gcloud iam roles describe "$NEW_ROLE_ID" --project "$PROJECT_ID" --format=json

echo "Custom role '$NEW_ROLE_ID' created and updated successfully in project '$PROJECT_ID'."

