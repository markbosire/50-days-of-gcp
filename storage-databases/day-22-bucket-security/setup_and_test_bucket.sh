#!/bin/bash

# Variables
PROJECT_ID=$(gcloud config get-value project) # Get current project ID
BUCKET_NAME="techcorp-financial-reports-$PROJECT_ID" # Unique bucket name using Project ID
LOCATION="us-central1"
FINANCE_TEAM_SA="finance-team-sa"
AUDITOR_SA="audit-sa"
EMPLOYEE_SA="employee-sa"
TEST_FILE="test_report.txt"
ACTIVE_USER=$(gcloud config get-value core/account) # Get the active user email

# Step 1: Create Service Accounts
echo "Creating service accounts..."
gcloud iam service-accounts create $FINANCE_TEAM_SA --display-name="Finance Team Service Account"
gcloud iam service-accounts create $AUDITOR_SA --display-name="Auditor Service Account"
gcloud iam service-accounts create $EMPLOYEE_SA --display-name="Employee Service Account"

# Step 2: Grant the active user the ability to impersonate the service accounts
echo "Granting impersonation permissions to the active user..."
gcloud iam service-accounts add-iam-policy-binding \
    $FINANCE_TEAM_SA@$PROJECT_ID.iam.gserviceaccount.com \
    --member="user:$ACTIVE_USER" \
    --role="roles/iam.serviceAccountTokenCreator"

gcloud iam service-accounts add-iam-policy-binding \
    $AUDITOR_SA@$PROJECT_ID.iam.gserviceaccount.com \
    --member="user:$ACTIVE_USER" \
    --role="roles/iam.serviceAccountTokenCreator"

gcloud iam service-accounts add-iam-policy-binding \
    $EMPLOYEE_SA@$PROJECT_ID.iam.gserviceaccount.com \
    --member="user:$ACTIVE_USER" \
    --role="roles/iam.serviceAccountTokenCreator"


sleep 30
# Step 4: Create the bucket
echo "Creating bucket: gs://$BUCKET_NAME..."
gcloud storage buckets create gs://$BUCKET_NAME --location=$LOCATION

# Step 5: Assign IAM Roles
echo "Granting access to the finance team..."
gcloud storage buckets add-iam-policy-binding gs://$BUCKET_NAME \
    --member="serviceAccount:$FINANCE_TEAM_SA@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.objectAdmin"

echo "Granting access to auditors..."
gcloud storage buckets add-iam-policy-binding gs://$BUCKET_NAME \
    --member="serviceAccount:$AUDITOR_SA@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.objectViewer"

# Step 6: Create a test file
echo "Creating a test file..."
echo "This is a sensitive financial report." > $TEST_FILE

# Step 7: Automated Tests
echo "Running automated tests..."

# Test 1: Finance Team Access
echo "Test 1: Finance team should be able to upload and list files (PASS if successful)."
gcloud storage cp $TEST_FILE gs://$BUCKET_NAME/ --impersonate-service-account="$FINANCE_TEAM_SA@$PROJECT_ID.iam.gserviceaccount.com"
if [ $? -eq 0 ]; then
    echo "Finance team can upload files: PASSED (Expected)"
else
    echo "Finance team can upload files: FAILED (Unexpected)"
fi

gcloud storage ls gs://$BUCKET_NAME/ --impersonate-service-account="$FINANCE_TEAM_SA@$PROJECT_ID.iam.gserviceaccount.com"
if [ $? -eq 0 ]; then
    echo "Finance team can list files: PASSED (Expected)"
else
    echo "Finance team can list files: FAILED (Unexpected)"
fi



# Test 2: Auditor Access
echo "Test 2: Auditors should be able to list files but not upload (PASS if behavior matches)."
gcloud storage cp $TEST_FILE gs://$BUCKET_NAME/ --impersonate-service-account="$AUDITOR_SA@$PROJECT_ID.iam.gserviceaccount.com"
if [ $? -ne 0 ]; then
    echo "Auditors cannot upload files: PASSED (Expected)"
else
    echo "Auditors cannot upload files: FAILED (Unexpected)"
fi

gcloud storage ls gs://$BUCKET_NAME/ --impersonate-service-account="$AUDITOR_SA@$PROJECT_ID.iam.gserviceaccount.com"
if [ $? -eq 0 ]; then
    echo "Auditors can list files: PASSED (Expected)"
else
    echo "Auditors can list files: FAILED (Unexpected)"
fi

# Test 3: Employee Access
echo "Test 3: Employees should not be able to upload or list files (PASS if behavior matches)."
gcloud storage cp $TEST_FILE gs://$BUCKET_NAME/ --impersonate-service-account="$EMPLOYEE_SA@$PROJECT_ID.iam.gserviceaccount.com"
if [ $? -ne 0 ]; then
    echo "Employees cannot upload files: PASSED (Expected)"
else
    echo "Employees cannot upload files: FAILED (Unexpected)"
fi

gcloud storage ls gs://$BUCKET_NAME/ --impersonate-service-account="$EMPLOYEE_SA@$PROJECT_ID.iam.gserviceaccount.com"
if [ $? -ne 0 ]; then
    echo "Employees cannot list files: PASSED (Expected)"
else
    echo "Employees cannot list files: FAILED (Unexpected)"
fi

# Step 8: Clean up
#echo "Cleaning up..."
#gcloud storage rm --recursive gs://$BUCKET_NAME
#rm $TEST_FILE
#gcloud iam service-accounts delete "$FINANCE_TEAM_SA@$PROJECT_ID.iam.gserviceaccount.com" --quiet
#gcloud iam service-accounts delete "$AUDITOR_SA@$PROJECT_ID.iam.gserviceaccount.com" --quiet
#gcloud iam service-accounts delete "$EMPLOYEE_SA@$PROJECT_ID.iam.gserviceaccount.com" --quiet

echo "Script completed."
