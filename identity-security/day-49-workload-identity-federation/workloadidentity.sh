#!/bin/bash

PROJECT_ID=$(gcloud config get-value project) 
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
CLUSTER_NAME="my-gke-cluster"
LOCATION="us-central1"
ZONE="us-central1-a"
NAMESPACE="default"
KSA_NAME="ksa-workload"
GSA_NAME="gsa-workload"
GSA_EMAIL="$GSA_NAME@$PROJECT_ID.iam.gserviceaccount.com"
BUCKET_NAME="test-bucket-${PROJECT_ID}"

# Enable required services
echo "Enabling required services..."
gcloud services enable container.googleapis.com iam.googleapis.com iamcredentials.googleapis.com storage.googleapis.com


# Create a GKE cluster with Workload Identity enabled
echo "Creating GKE cluster with Workload Identity..."
gcloud container clusters create "$CLUSTER_NAME" \
    --zone="$ZONE" \
    --workload-pool="$PROJECT_ID.svc.id.goog" \
    --num-nodes=1 \
    --disk-size=50 \
    --enable-autoscaling \
    --min-nodes=1 \
    --max-nodes=3
    

# Get cluster credentials
echo "Getting cluster credentials..."
gcloud container clusters get-credentials "$CLUSTER_NAME" --zone="$zone"

# Create a Kubernetes namespace (if not using default)
# kubectl create namespace "$NAMESPACE"

# Create a Kubernetes Service Account (KSA)
echo "Creating Kubernetes Service Account..."
kubectl create serviceaccount "$KSA_NAME" \
    --namespace "$NAMESPACE"

# Create a Google Service Account (GSA)
echo "Creating Google Service Account..."
gcloud iam service-accounts create "$GSA_NAME" \
    --display-name="GKE Workload Identity SA"

# Allow KSA to impersonate GSA
echo "Setting up IAM binding for Workload Identity..."
gcloud iam service-accounts add-iam-policy-binding "$GSA_EMAIL" \
    --role="roles/iam.workloadIdentityUser" \
    --member="serviceAccount:$PROJECT_ID.svc.id.goog[$NAMESPACE/$KSA_NAME]"

# Annotate KSA
echo "Annotating Kubernetes Service Account..."
kubectl annotate serviceaccount "$KSA_NAME" \
    --namespace "$NAMESPACE" \
    iam.gke.io/gcp-service-account="$GSA_EMAIL"

# Create test bucket and grant access
echo "Creating test bucket and granting access..."
gcloud storage buckets create "gs://$BUCKET_NAME" || true
gcloud storage buckets add-iam-policy-binding "gs://$BUCKET_NAME" \
    --member="serviceAccount:$GSA_EMAIL" \
    --role="roles/storage.objectViewer"
# Upload sample objects to the bucket

echo "sample">> sample1.txt
echo "sample 2">> sample2.txt
echo "Uploading objects to the bucket..."
gcloud storage cp sample1.txt sample2.txt "gs://$BUCKET_NAME/"
# Deploy test pod
echo "Deploying test pod..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
  namespace: $NAMESPACE
spec:
  serviceAccountName: $KSA_NAME
  containers:
  - name: test-pod
    image: gcr.io/google.com/cloudsdktool/cloud-sdk:slim
    command: ["sleep", "infinity"]
    resources:
      limits:
        cpu: "1"
        ephemeral-storage: "5Gi"
        memory: "1Gi"
      requests:
        cpu: "0.5"
        ephemeral-storage: "5Gi"
        memory: "1Gi"
EOF


# Wait for pod to be ready
echo "Waiting for test pod to be ready..."
kubectl wait --for=condition=ready pod/test-pod --namespace="$NAMESPACE" --timeout=300s

# Test the workload identity setup
echo "Testing Workload Identity setup..."
kubectl exec -it test-pod --namespace="$NAMESPACE" -- \
    curl -X GET -H "Authorization: Bearer $(kubectl exec -it test-pod --namespace=$NAMESPACE -- gcloud auth print-access-token)" \
    "https://storage.googleapis.com/storage/v1/b/$BUCKET_NAME/o"

echo "Workload Identity setup complete!"
