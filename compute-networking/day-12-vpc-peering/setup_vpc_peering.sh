#!/bin/bash

# Variables
PROJECT_ID=$(gcloud config get-value project)
REGION="us-central1"
ZONE="us-central1-a"
PRODUCTION_VPC="production-vpc"
DEVELOPMENT_VPC="development-vpc"
PRODUCTION_SUBNET="production-subnet"
DEVELOPMENT_SUBNET="development-subnet"
PRODUCTION_VM="production-vm"
DEVELOPMENT_VM="development-vm"
PRODUCTION_VM_TAG="production-vm"

# Step 1: Create the VPCs
echo "Creating VPCs..."
gcloud compute networks create $PRODUCTION_VPC --subnet-mode=custom
gcloud compute networks create $DEVELOPMENT_VPC --subnet-mode=custom

# Step 2: Create Subnets in Each VPC
echo "Creating subnets..."
gcloud compute networks subnets create $PRODUCTION_SUBNET \
    --network=$PRODUCTION_VPC \
    --range=10.0.1.0/24 \
    --region=$REGION

gcloud compute networks subnets create $DEVELOPMENT_SUBNET \
    --network=$DEVELOPMENT_VPC \
    --range=10.0.2.0/24 \
    --region=$REGION

# Step 3: Create VMs in Each VPC
echo "Creating VMs..."
gcloud compute instances create $PRODUCTION_VM \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --subnet=$PRODUCTION_SUBNET \
    --tags=$PRODUCTION_VM_TAG \
    --image-family=debian-11 \
    --image-project=debian-cloud

gcloud compute instances create $DEVELOPMENT_VM \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --subnet=$DEVELOPMENT_SUBNET \
    --image-family=debian-11 \
    --image-project=debian-cloud

# Step 4: Set Up VPC Peering
echo "Setting up VPC peering..."
gcloud compute networks peerings create dev-to-prod-peering \
    --network=$DEVELOPMENT_VPC \
    --peer-network=$PRODUCTION_VPC

gcloud compute networks peerings create prod-to-dev-peering \
    --network=$PRODUCTION_VPC \
    --peer-network=$DEVELOPMENT_VPC

# Step 5: Configure Firewall Rules
echo "Configuring firewall rules..."
gcloud compute firewall-rules create allow-ssh-anywhere-production \
    --network=$PRODUCTION_VPC \
    --source-ranges=0.0.0.0/0 \
    --allow=tcp:22 \
    --target-tags=$PRODUCTION_VM_TAG

gcloud compute firewall-rules create allow-ssh-anywhere-development \
    --network=$DEVELOPMENT_VPC \
    --source-ranges=0.0.0.0/0 \
    --allow=tcp:22

gcloud compute firewall-rules create allow-icmp-dev-to-prod \
    --network=$PRODUCTION_VPC \
    --source-ranges=10.0.2.0/24 \
    --allow=icmp \
    --target-tags=$PRODUCTION_VM_TAG

# Step 6: Fetch the Internal IP of the Production VM
echo "Fetching internal IP of production-vm..."
PRODUCTION_VM_IP=$(gcloud compute instances describe $PRODUCTION_VM \
    --zone=$ZONE \
    --format="value(networkInterfaces[0].networkIP)")

if [ -z "$PRODUCTION_VM_IP" ]; then
    echo "Failed to fetch the internal IP of production-vm."
    exit 1
fi

echo "Internal IP of production-vm: $PRODUCTION_VM_IP"

# Step 7: Test Connectivity Using `ping` with `--command` Flag
echo "Testing connectivity from development-vm to production-vm..."
gcloud compute ssh $DEVELOPMENT_VM \
    --zone=$ZONE \
    --command="ping -c 4 $PRODUCTION_VM_IP"

echo "Script completed successfully."
