# Google Cloud IAM and Storage Automation Script

This script automates the creation and configuration of Google Cloud service accounts, storage buckets, and IAM roles. It also includes automated tests to verify permissions for different user roles.

## Script Overview

1. **Service Account Creation**: Creates three service accounts for the finance team, auditors, and employees.
2. **Impersonation Permissions**: Grants the active user the ability to impersonate the service accounts.
3. **Storage Bucket Creation**: Creates a Google Cloud Storage bucket with a unique name.
4. **IAM Role Assignment**: Assigns appropriate roles to the service accounts for accessing the bucket.
5. **Test File Creation**: Generates a test file for permission testing.
6. **Automated Tests**: Verifies permissions for each service account:
   - Finance team: Can upload and list files.
   - Auditors: Can list files but cannot upload.
   - Employees: Cannot upload or list files.
7. **Cleanup**: (Optional) Removes created resources (commented out by default).

## How to Use

1. Ensure you have the Google Cloud SDK installed and authenticated.
2. Run the script in a bash environment:
   ```bash
   bash script_name.sh
   ```
Review the output to verify the results of the automated tests.
## Clean up
```bash
PROJECT_ID=$(gcloud config get-value project) # Get current project ID
BUCKET_NAME="techcorp-financial-reports-$PROJECT_ID" # Unique bucket name using Project ID
LOCATION="us-central1"
FINANCE_TEAM_SA="finance-team-sa"
AUDITOR_SA="audit-sa"
EMPLOYEE_SA="employee-sa"
TEST_FILE="test_report.txt"
ACTIVE_USER=$(gcloud config get-value core/account) # Get the active user email
gcloud storage rm --recursive gs://$BUCKET_NAME
rm $TEST_FILE
gcloud iam service-accounts remove-iam-policy-binding \
    $FINANCE_TEAM_SA@$PROJECT_ID.iam.gserviceaccount.com \
    --member="user:$ACTIVE_USER" \
    --role="roles/iam.serviceAccountTokenCreator"

gcloud iam service-accounts remove-iam-policy-binding \
    $AUDITOR_SA@$PROJECT_ID.iam.gserviceaccount.com \
    --member="user:$ACTIVE_USER" \
    --role="roles/iam.serviceAccountTokenCreator"

gcloud iam service-accounts remove-iam-policy-binding \
    $EMPLOYEE_SA@$PROJECT_ID.iam.gserviceaccount.com \
    --member="user:$ACTIVE_USER" \
    --role="roles/iam.serviceAccountTokenCreator"
gcloud iam service-accounts delete "$FINANCE_TEAM_SA@$PROJECT_ID.iam.gserviceaccount.com" --quiet
gcloud iam service-accounts delete "$AUDITOR_SA@$PROJECT_ID.iam.gserviceaccount.com" --quiet
gcloud iam service-accounts delete "$EMPLOYEE_SA@$PROJECT_ID.iam.gserviceaccount.com" --quiet
```
