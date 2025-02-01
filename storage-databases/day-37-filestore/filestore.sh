#!/bin/bash

# Variables
PROJECT_ID=$(gcloud config get-value project)
REGION="us-central1"
ZONE="us-central1-a"
VPC_NETWORK_NAME="custom-vpc-network"
SUBNET_NAME="custom-subnet"
FIREWALL_RULE_NAME="allow-ssh"
INSTANCE_NAME="nfs-client"
FILESTORE_INSTANCE_NAME="nfs-server"
FILESTORE_FILE_SHARE_NAME="vol1"
MOUNT_DIR="/mnt/test"

# Task 0: Enable APis and Create a custom VPC network and subnet
echo "Enabling necessary APIs..."
gcloud services enable file.googleapis.com
gcloud services enable compute.googleapis.com

echo "Creating custom VPC network and subnet..."
gcloud compute networks create $VPC_NETWORK_NAME \
    --subnet-mode=custom

gcloud compute networks subnets create $SUBNET_NAME \
    --network=$VPC_NETWORK_NAME \
    --range=10.0.0.0/24 \
    --region=$REGION

echo "Custom VPC network and subnet created."

# Task 0.1: Create a firewall rule to allow SSH from anywhere
echo "Creating firewall rule to allow SSH from anywhere..."
gcloud compute firewall-rules create $FIREWALL_RULE_NAME \
    --network=$VPC_NETWORK_NAME \
    --allow=tcp:22 \
    --source-ranges=0.0.0.0/0 \
    --description="Allow SSH from anywhere"

echo "Firewall rule created to allow SSH from anywhere."

# Task 1: Create a Compute Engine instance in the custom VPC
echo "Creating Compute Engine instance in the custom VPC..."
gcloud compute instances create $INSTANCE_NAME \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --network=$VPC_NETWORK_NAME \
    --subnet=$SUBNET_NAME \
    --tags=http-server \
    --metadata=startup-script="#!/bin/bash
        apt-get update
        apt-get install -y nfs-common"

echo "Compute Engine instance created: $INSTANCE_NAME"

# Task 2: Create a Cloud Filestore instance in the custom VPC
echo "Creating Cloud Filestore instance in the custom VPC..."
gcloud filestore instances create $FILESTORE_INSTANCE_NAME \
    --zone=$ZONE \
    --tier=BASIC_HDD \
    --file-share=name=$FILESTORE_FILE_SHARE_NAME,capacity=1TB \
    --network=name=$VPC_NETWORK_NAME

echo "Cloud Filestore instance created: $FILESTORE_INSTANCE_NAME"

# Wait for Filestore instance to be ready
echo "Waiting for Filestore instance to be ready..."
while [[ $(gcloud filestore instances describe $FILESTORE_INSTANCE_NAME --zone=$ZONE --format="value(state)") != "READY" ]]; do
    sleep 10
done
echo "Filestore instance is ready."

# Get the IP address of the Filestore instance
FILESTORE_IP=$(gcloud filestore instances describe $FILESTORE_INSTANCE_NAME --zone=$ZONE --format="value(networks.ipAddresses[0])")
echo "Filestore instance IP: $FILESTORE_IP"

# Task 3: Mount the Cloud Filestore file share on the Compute Engine VM
echo "Mounting Cloud Filestore file share on Compute Engine VM..."
gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --command="
    sudo mkdir -p $MOUNT_DIR &&
    sudo mount $FILESTORE_IP:/$FILESTORE_FILE_SHARE_NAME $MOUNT_DIR &&
    sudo chmod go+rw $MOUNT_DIR"

echo "Cloud Filestore file share mounted at $MOUNT_DIR"

# Task 4: Create a file on the file share
echo "Creating a file on the file share..."
gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --command="
    echo 'This is a test' > $MOUNT_DIR/testfile &&
    ls $MOUNT_DIR &&
    cat $MOUNT_DIR/testfile"

echo "File created and verified on the file share."

echo "Lab tasks completed successfully!"
