# Workload Identity Setup on GKE

## Overview
This script automates the setup of **Workload Identity** on a **Google Kubernetes Engine (GKE)** cluster. Workload Identity allows Kubernetes workloads to authenticate securely with Google Cloud services without using long-lived service account keys.

## Features
- Enables necessary Google Cloud services
- Creates a GKE cluster with Workload Identity enabled
- Configures Kubernetes and Google service accounts (KSA and GSA)
- Grants the necessary IAM permissions
- Deploys a test pod to verify access to Google Cloud Storage

## Prerequisites
Ensure you have:
- A **Google Cloud project** set up
- **`gcloud` CLI** and **`kubectl`** installed and authenticated
- Necessary permissions to create and manage GKE, IAM, and Cloud Storage resources

## Setup and Execution
1. Clone or download this script.
2. Make the script executable:
   ```sh
   chmod +x setup-workload-identity.sh
   ```
3. Run the script:
   ```sh
   ./setup-workload-identity.sh
   ```

## Resources Created
- **GKE Cluster** (`my-gke-cluster`)
- **Kubernetes Service Account (KSA)** (`ksa-workload`)
- **Google Service Account (GSA)** (`gsa-workload`)
- **IAM Policy Binding** between KSA and GSA
- **Cloud Storage Bucket** (`test-bucket-<PROJECT_ID>`)
- **Test Kubernetes Pod** (`test-pod`)

## Verification
Once the script completes, you can manually verify Workload Identity by running:
```sh
kubectl exec -it test-pod --namespace=default -- gcloud auth print-access-token
```
This should return a valid authentication token.

## Cleanup
To remove all resources created by this script:
```sh
kubectl delete pod test-pod --namespace=default
kubectl delete serviceaccount ksa-workload --namespace=default
gcloud container clusters delete my-gke-cluster --zone=us-central1-a --quiet
```



