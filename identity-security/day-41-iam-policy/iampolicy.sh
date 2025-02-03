#!/bin/bash
# Script to test IAM conditions with uniform bucket-level access
PROJECT_ID=$(gcloud config get-value project)
BUCKET_NAME="logs-bucket-${PROJECT_ID}"
SERVICE_ACCOUNT_NAME="log-analyzer-sa"
SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# Enable required services
gcloud services enable iam.googleapis.com storage-component.googleapis.com --quiet

# Create storage bucket with uniform bucket-level access enabled
echo "Creating bucket with uniform bucket-level access..."
gcloud storage buckets create "gs://${BUCKET_NAME}" \
    --location=us-central1 \
    --uniform-bucket-level-access

# Create test files and upload to bucket
echo "Creating and uploading test files..."
echo "Public log content" > public.log
echo "Confidential content" > secret.log
gcloud storage cp public.log "gs://${BUCKET_NAME}/logs/public/"
gcloud storage cp secret.log "gs://${BUCKET_NAME}/logs/confidential/"
rm public.log secret.log

# Create service account
echo "Creating service account..."
gcloud iam service-accounts create ${SERVICE_ACCOUNT_NAME} \
    --display-name="Log Analyzer Service Account"

# Grant the user the Service Account Token Creator role
echo "Granting Service Account Token Creator role..."
gcloud iam service-accounts add-iam-policy-binding ${SERVICE_ACCOUNT_EMAIL} \
    --member="user:$(gcloud config get-value core/account)" \
    --role="roles/iam.serviceAccountTokenCreator" \
    --condition=None

# Step 1: Apply role binding WITHOUT condition
echo "Applying role binding WITHOUT condition..."
gcloud storage buckets add-iam-policy-binding "gs://${BUCKET_NAME}" \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/storage.objectViewer"

echo "Waiting 0 seconds for IAM propagation..."
sleep 120

# Test 1: Access public file WITHOUT condition
echo "TEST 1: Access public file WITHOUT condition"
gcloud storage cat "gs://${BUCKET_NAME}/logs/public/public.log" \
    --impersonate-service-account="${SERVICE_ACCOUNT_EMAIL}"

# Test 2: Access confidential file WITHOUT condition
echo "TEST 2: Access confidential file WITHOUT condition"
gcloud storage cat "gs://${BUCKET_NAME}/logs/confidential/secret.log" \
    --impersonate-service-account="${SERVICE_ACCOUNT_EMAIL}"

# Step 2: Update role binding to ADD condition
echo "Updating role binding to ADD condition..."
gcloud storage buckets remove-iam-policy-binding "gs://${BUCKET_NAME}" \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/storage.objectViewer"
gcloud storage buckets add-iam-policy-binding "gs://${BUCKET_NAME}" \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/storage.objectViewer" \
    --condition="expression=resource.name.startsWith(\"projects/_/buckets/${BUCKET_NAME}/objects/logs/public/\"),title=public_logs_only"

echo "Waiting 30 seconds for IAM propagation..."
sleep 30

# Test 3: Access public file WITH condition
echo "TEST 3: Access public file WITH condition"
gcloud storage cat "gs://${BUCKET_NAME}/logs/public/public.log" \
    --impersonate-service-account="${SERVICE_ACCOUNT_EMAIL}"

# Test 4: Access confidential file WITH condition
echo "TEST 4: Access confidential file WITH condition"
gcloud storage cat "gs://${BUCKET_NAME}/logs/confidential/secret.log" \
    --impersonate-service-account="${SERVICE_ACCOUNT_EMAIL}" || true
