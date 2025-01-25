# Cloud KMS Encryption Script

This script automates the process of setting up and using Google Cloud Key Management Service (KMS) to encrypt files stored in a Google Cloud Storage bucket.

## Prerequisites

- Google Cloud SDK installed and configured.
- Authenticated Google Cloud account with a project set.

## Script Overview

The script performs the following tasks:

1. **Retrieve Project ID**: Fetches the current Google Cloud project ID.
2. **Create Cloud Storage Bucket**: Creates a new bucket in the specified region.
3. **Create Sample Files**: Generates three sample text files.
4. **Enable Cloud KMS**: Enables the Cloud KMS API for the project.
5. **Create KeyRing and CryptoKeys**: Sets up a KeyRing and two CryptoKeys for encryption.
6. **Grant Permissions**: Grants necessary permissions to the default Cloud Storage service account.
7. **Set Default Encryption Key**: Configures the default encryption key for the bucket.
8. **Upload and Encrypt Files**: Uploads files to the bucket, applying encryption as specified.
9. **Verify Encryption**: Checks and verifies the encryption keys used for the uploaded files.

## Usage

1. Ensure you have the Google Cloud SDK installed and configured.
2. Run the script in your terminal:
   ```bash
   ./encrypt.sh
