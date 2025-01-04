
# Encryption VM Setup Script

This script automates the setup of a Google Cloud environment for encrypting and storing files securely. It creates a Virtual Private Cloud (VPC), a service account, a VM instance, and a Cloud Storage bucket. The script also configures firewall rules for secure SSH access and demonstrates how to upload and download files to/from the VM and the bucket.

## Prerequisites

- Google Cloud SDK installed and configured.
- A Google Cloud project with billing enabled.

## Script Overview

1. **Enable Required APIs**: Enables necessary Google Cloud APIs for compute, storage, IAM, and identity toolkit.
2. **Create VPC Network**: Sets up a custom VPC network and subnet.
3. **Create Service Account**: Creates a service account for the VM and grants it the Storage Admin role.
4. **Create VM Instance**: Launches a VM instance with the created service account.
5. **Create Storage Bucket**: Creates a Cloud Storage bucket for storing encrypted files.
6. **Firewall Rule for SSH**: Configures a firewall rule to allow SSH access via Identity-Aware Proxy (IAP).
7. **Upload Test File**: Creates a test file and uploads it to the VM.
8. **Upload File to Bucket**: Uploads the test file from the VM to the Cloud Storage bucket.

## Usage

1. Clone the repository or download the script.
2. Make the script executable:
   ```bash
   chmod +x setup_encryptionvm.sh
   ```
3. Run the script:
   ```bash
   ./setup_encryptionvm.sh
   ```

## Cleanup commands
```bash
gcloud compute instances delete encryption-vm --zone=us-central1-a --quiet

gcloud compute firewall-rules delete allow-ssh-iap --quiet

gcloud compute networks subnets delete my-subnet --region=us-central1 --quiet

gcloud compute networks delete my-vpc --quiet

gcloud iam service-accounts delete encryption-vm-sa@$(gcloud config get-value project).iam.gserviceaccount.com --quiet

gcloud storage rm --recursive gs://$(gcloud config get-value project)-my-encrypted-files --quiet

rm -f password.txt downloaded_password.txt
```
