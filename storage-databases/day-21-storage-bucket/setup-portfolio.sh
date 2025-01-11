#!/bin/bash

# Get the default project ID
PROJECT_ID=$(gcloud config get-value project)

# Combine project name with "portfolio" to create the bucket name
BUCKET_NAME="${PROJECT_ID}-portfolio"

# Region for the bucket (change if needed)
LOCATION="US"

# Step 1: Create a new bucket
echo "Creating bucket: ${BUCKET_NAME}"
gcloud storage buckets create gs://${BUCKET_NAME} --location=${LOCATION}

# Step 2: Upload website files to the bucket
echo "Uploading website files to the bucket..."
gcloud storage cp . gs://${BUCKET_NAME} --recursive

# Step 3: Set bucket permissions to make it publicly accessible
echo "Setting bucket permissions..."
gcloud storage buckets add-iam-policy-binding gs://${BUCKET_NAME} \
  --member=allUsers \
  --role=roles/storage.objectViewer

# Step 4: Enable static website hosting
echo "Enabling static website hosting..."
gcloud storage buckets update gs://${BUCKET_NAME} --web-main-page-suffix=index.html

# Step 5: Display the website URL
echo "Your website is live at: https://${BUCKET_NAME}.storage.googleapis.com/index.html"
