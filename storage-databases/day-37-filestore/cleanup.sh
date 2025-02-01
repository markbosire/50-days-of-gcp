#!/bin/bash

# Variables (matching the original script)
PROJECT_ID=$(gcloud config get-value project)
REGION="us-central1"
ZONE="us-central1-a"
VPC_NETWORK_NAME="custom-vpc-network"
SUBNET_NAME="custom-subnet"
FIREWALL_RULE_NAME="allow-ssh"
INSTANCE_NAME="nfs-client"
FILESTORE_INSTANCE_NAME="nfs-server"
MOUNT_DIR="/mnt/test"

echo "Starting cleanup process..."

# Step 1: Unmount the Filestore share from the Compute Engine instance
echo "Unmounting Filestore share..."
gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --command="
    sudo umount $MOUNT_DIR" || echo "Warning: Unable to unmount. Instance may already be deleted."

# Step 2: Delete the Compute Engine instance
echo "Deleting Compute Engine instance..."
gcloud compute instances delete $INSTANCE_NAME \
    --zone=$ZONE \
    --quiet || echo "Warning: Instance may already be deleted"

# Step 3: Delete the Filestore instance
echo "Deleting Filestore instance..."
gcloud filestore instances delete $FILESTORE_INSTANCE_NAME \
    --zone=$ZONE \
    --quiet || echo "Warning: Filestore instance may already be deleted"

# Step 4: Delete the firewall rule
echo "Deleting firewall rule..."
gcloud compute firewall-rules delete $FIREWALL_RULE_NAME \
    --quiet || echo "Warning: Firewall rule may already be deleted"

# Step 5: Delete the subnet
echo "Deleting subnet..."
gcloud compute networks subnets delete $SUBNET_NAME \
    --region=$REGION \
    --quiet || echo "Warning: Subnet may already be deleted"

# Step 6: Delete the VPC network
echo "Deleting VPC network..."
gcloud compute networks delete $VPC_NETWORK_NAME \
    --quiet || echo "Warning: VPC network may already be deleted"

echo "Cleanup completed!"
