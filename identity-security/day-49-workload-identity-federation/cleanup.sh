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

# Delete test pod and PVC
echo "Deleting test pod and PersistentVolumeClaim..."
kubectl delete pod test-pod --namespace "$NAMESPACE" --ignore-not-found
kubectl delete pvc test-pvc --namespace "$NAMESPACE" --ignore-not-found

# Remove IAM policy binding for Workload Identity
echo "Removing IAM policy binding..."
gcloud iam service-accounts remove-iam-policy-binding "$GSA_EMAIL" \
    --role="roles/iam.workloadIdentityUser" \
    --member="serviceAccount:$PROJECT_ID.svc.id.goog[$NAMESPACE/$KSA_NAME]"

# Delete Kubernetes Service Account (KSA)
echo "Deleting Kubernetes Service Account..."
kubectl delete serviceaccount "$KSA_NAME" --namespace "$NAMESPACE" --ignore-not-found

# Delete Google Service Account (GSA)
echo "Deleting Google Service Account..."
gcloud iam service-accounts delete "$GSA_EMAIL" --quiet

# Delete test bucket
echo "Deleting test bucket..."
gcloud storage rm --recursive "gs://$BUCKET_NAME"

# Delete GKE cluster
echo "Deleting GKE cluster..."
gcloud container clusters delete "$CLUSTER_NAME" --zone "$ZONE" --quiet

echo "Cleanup complete!"

