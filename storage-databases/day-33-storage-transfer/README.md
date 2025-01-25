# AWS S3 to Google Cloud Storage Transfer Script

This script automates the transfer of data from an AWS S3 bucket to a Google Cloud Storage (GCS) bucket using Google Cloud's Storage Transfer Service. It creates a GCS bucket, configures permissions, initiates the transfer job, and performs a basic verification of the transferred data.

## Features

- Creates a Google Cloud Storage bucket.
- Enables the required Storage Transfer API.
- Grants necessary permissions to the Storage Transfer Service account.
- Initiates a transfer job for specified S3 objects to GCS.
- Verifies object metadata post-transfer.

## Prerequisites

1. **Google Cloud SDK**: Installed and initialized on your machine.
2. **Authentication**: Logged in via `gcloud auth login` with sufficient permissions (roles: `storage.admin`, `iam.serviceAccountAdmin`).
3. **AWS S3 Access**: Ensure the source S3 bucket (`power-datastore`) is accessible. The script assumes public access or proper IAM roles are already configured.

## Usage

1. **Save the Script**: Copy the provided Bash script into a file .
2. **Make Executable**:
   ```bash
   chmod +x transfer.sh
   ```
3. **Run the Script**:
   ```bash
   ./transfer.sh
   ```

## Script Steps

1. **Create GCS Bucket**: A bucket named `test-storage-bucket-<PROJECT_NUMBER>` is created in the `US` region.
2. **Enable Storage Transfer API**: Activates the required Google Cloud service.
3. **Grant Permissions**: Assigns `storage.admin` role to the Storage Transfer Service account.
4. **Start Transfer Job**: Copies objects from `s3://power-datastore/v9/daily/2025/01/` to the GCS bucket.
5. **Verify Metadata**: Lists transferred objects after a 60-second delay (adjust sleep time as needed).
