#!/bin/bash

# Set variables
PROJECT_ID=$(gcloud config get-value project)
SERVICE_ACCOUNT_NAME="predefined-role-test-sa"
SERVICE_ACCOUNT_EMAIL="$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"
ZONE="us-central1-a"

# Create a service account
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
    --description="Testing multiple predefined roles" \
    --display-name="Predefined Role Test SA"

gcloud iam service-accounts add-iam-policy-binding predefined-role-test-sa@$PROJECT_ID.iam.gserviceaccount.com \
    --member="user:$(gcloud config get-value account)" \
    --role="roles/iam.serviceAccountTokenCreator"

wait 120

# Assign roles to the service account
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" --role="roles/viewer"
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" --role="roles/logging.viewer"
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" --role="roles/compute.admin"
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" --role="roles/iam.serviceAccountUser"

# Test: List Compute Engine instances (should succeed)
echo "Testing instance listing..."
gcloud compute instances list --project=$PROJECT_ID --impersonate-service-account=$SERVICE_ACCOUNT_EMAIL

# Test: View Cloud Logging logs (should succeed)
echo "Testing log access..."
gcloud logging read "resource.type=gce_instance" --limit 3 --impersonate-service-account=$SERVICE_ACCOUNT_EMAIL

# Test: Create a Compute Engine instance (should succeed)
echo "Testing instance creation..."
gcloud compute instances create test-instance --zone=$ZONE --project=$PROJECT_ID --impersonate-service-account=$SERVICE_ACCOUNT_EMAIL

# Test: Try creating another service account (should fail)
echo "Testing service account creation (should fail)..."
gcloud iam service-accounts create unauthorized-test-sa --impersonate-service-account=$SERVICE_ACCOUNT_EMAIL

# Cleanup
echo "Cleaning up..."
echo "gcloud compute instances delete test-instance --zone=$ZONE --quiet --impersonate-service-account=$SERVICE_ACCOUNT_EMAIL
gcloud iam service-accounts delete $SERVICE_ACCOUNT_EMAIL --quiet"

