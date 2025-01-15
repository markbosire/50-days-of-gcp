# Firestore Data Generator Setup

This script automates the setup of a Google Cloud environment to generate and view fake data in Firestore. It performs the following steps:

1. **Enable necessary APIs** for Firestore, Compute Engine, and Cloud Resource Manager.
2. **Create a Firestore database** in the specified region.
3. **Provision a VM instance** with Python and required dependencies installed.
4. **Set up a firewall rule** to allow SSH access to the VM.
5. **Generate fake data** and add it to the Firestore database.
6. **View the data** stored in Firestore.

## Prerequisites

- Google Cloud SDK installed and configured.
- A Google Cloud project with billing enabled.

## Usage

1. Make the script executable: `chmod +x script.sh`.
2. Run the script: `./script.sh`.

The script will automatically fetch your Google Cloud project ID and perform the setup.

## Clean Up

```
gcloud compute instances delete firestore-data-generator --zone=us-central1-a

gcloud firestore databases delete --database=firestore-database

gcloud compute firewall-rules delete allow-ssh
```
