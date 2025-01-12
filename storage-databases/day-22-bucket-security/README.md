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
