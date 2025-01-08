# Deployment Setup for Small Company Environment

This script deploys and describes instances in a Google Cloud environment using Deployment Manager and Google Cloud SDK.

## Steps

1. **Create Deployment:**
   The following command creates a deployment for a small company environment using a YAML configuration file:

   ```bash
   echo "Creating deployment..."
   gcloud deployment-manager deployments create small-company-env --config small-env-vm-config.yaml
   ```

2. **Check Deployment Status:**
   After the deployment is created, check the status using the command below:

   ```bash
   echo "Checking deployment status..."
   gcloud deployment-manager deployments describe small-company-env
   ```

3. **Describe Instances:**
   Once the deployment is active, you can describe the individual instances (test, staging, and production) using the following commands.

   - **Test Instance:**
     ```bash
     echo "Describing test-instance..."
     gcloud compute instances describe test-instance --zone=us-central1-a
     ```

   - **Staging Instance:**
     ```bash
     echo "Describing staging-instance..."
     gcloud compute instances describe staging-instance --zone=us-central1-a
     ```

   - **Production Instance:**
     ```bash
     echo "Describing prod-instance..."
     gcloud compute instances describe prod-instance --zone=us-central1-a
     ```

## Prerequisites

- Google Cloud SDK must be installed and authenticated.
- The `small-env-vm-config.yaml` file must be properly configured with the necessary VM instance details.

## Usage

Run the script in your terminal or as part of your CI/CD pipeline to deploy and manage instances for your environment.
 ```bash
  bash setup-deployment.sh     
 ```
