# Secure Employee Portal IAP Setup
Simple script to deploy an IAP-protected web server on Google Cloud.

## Prerequisites
- Google Cloud SDK installed
- Project with billing enabled
- IAM permissions:
  - Compute Admin
  - IAP Security Admin
  - IAM Admin

## Features
- Automated VM deployment
- IAP tunnel configuration
- HTTP/SSH access control
- Easy cleanup

## Usage
```bash
bash iap.sh 
```

## What It Does
1. Creates Ubuntu VM with Apache
2. Configures firewall rules
3. Sets up IAP access
4. Creates secure tunnel

## Cleaning Up
```bash
gcloud compute instances delete hypernova-server --zone=us-west1-b --quiet
gcloud compute firewall-rules delete allow-http --quiet
gcloud compute firewall-rules delete allow-iap --quiet
gcloud projects remove-iam-policy-binding $(gcloud config get-value project) \
    --member="user:$(gcloud config get-value account)" \
    --role=roles/iap.tunnelResourceAccessor --quiet
```

## Security Notes
- Only allows access through IAP tunnel
- Blocks direct internet access
- Requires Google authentication
- Limited to specific IP ranges

## Troubleshooting
- Check IAM permissions
- Verify firewall rules
- Ensure IAP is enabled
- Wait for VM initialization
