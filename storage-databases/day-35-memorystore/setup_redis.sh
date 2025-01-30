#!/bin/bash

# Variables
PROJECT_ID=$(gcloud config get-value project)
REGION="us-central1"  # Change to your preferred region
ZONE="${REGION}-a"  # Use the appropriate zone for your region
VPC_NAME="my-vpc"
SUBNET_NAME="my-subnet"
VM_NAME="test-vm"
INSTANCE_ID="my-instance-1"
DISPLAY_NAME="My Quickstart Instance"
CAPACITY=5  # in GB
TIER="standard"
REDIS_VERSION="redis_5_0"
READ_REPLICAS=1
FIREWALL_RULE_SSH="allow-ssh"
FIREWALL_RULE_INTERNAL="allow-internal"

# Enable required APIs if not already enabled
gcloud services enable compute.googleapis.com redis.googleapis.com --project=$PROJECT_ID

# Create a VPC network
gcloud compute networks create $VPC_NAME \
    --project=$PROJECT_ID \
    --subnet-mode=custom

# Create a subnet within the VPC
gcloud compute networks subnets create $SUBNET_NAME \
    --network=$VPC_NAME \
    --region=$REGION \
    --range=10.0.1.0/24

# Create a firewall rule to allow SSH (port 22) from anywhere
gcloud compute firewall-rules create $FIREWALL_RULE_SSH \
    --network=$VPC_NAME \
    --allow tcp:22 \
    --source-ranges=0.0.0.0/0 \
    --description="Allow SSH access from anywhere" \
    --project=$PROJECT_ID

# Create a firewall rule to allow internal traffic (Redis port 6379)
gcloud compute firewall-rules create $FIREWALL_RULE_INTERNAL \
    --network=$VPC_NAME \
    --allow tcp:6379 \
    --source-ranges=10.0.1.0/24 \
    --description="Allow internal Redis traffic" \
    --project=$PROJECT_ID

# Create a Compute Engine VM instance in the newly created VPC
gcloud compute instances create $VM_NAME \
    --zone=$ZONE \
    --network=$VPC_NAME \
    --subnet=$SUBNET_NAME \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --machine-type=e2-medium \
    --tags=http-server,https-server \
    --metadata=startup-script='#! /bin/bash
apt-get update
apt-get install -y telnet
' \
    --project=$PROJECT_ID

echo "VPC, Subnet, Firewall Rules, and VM instance have been created successfully."

# Create Redis instance with read replicas
gcloud redis instances create $INSTANCE_ID \
    --size=$CAPACITY \
    --region=$REGION \
    --tier=$TIER \
    --redis-version=$REDIS_VERSION \
    --read-replicas-mode=read-replicas-enabled \
    --replica-count=$READ_REPLICAS \
    --display-name="$DISPLAY_NAME" \
    --network=$VPC_NAME \
    --project=$PROJECT_ID

echo "Waiting for the Redis instance to be created..."
sleep 60  # Adjust the sleep time as needed

# Get the IP address of the Redis instance
IP_ADDRESS=$(gcloud redis instances describe $INSTANCE_ID --region=$REGION --project=$PROJECT_ID --format="value(host)")

echo "Redis instance created successfully at IP: $IP_ADDRESS"

# SSH into the VM instance and connect to Redis

gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command="{ echo 'PING'; sleep 1; echo 'SET HELLO WORLD'; sleep 1; echo 'GET HELLO'; sleep 1; } | telnet $IP_ADDRESS 6379"


# Scale the Redis instance by changing the number of read replicas
NEW_READ_REPLICAS=5  # Change this to the desired number of read replicas

# Update the Redis instance
gcloud redis instances update $INSTANCE_ID \
    --region=$REGION \
    --replica-count=$NEW_READ_REPLICAS \
    --project=$PROJECT_ID

echo "Scaling Redis instance to $NEW_READ_REPLICAS read replicas..."

# Wait for the instance to finish updating
sleep 60  # Adjust the sleep time as needed

# Verify the Redis instance has scaled
gcloud redis instances describe $INSTANCE_ID --region=$REGION --project=$PROJECT_ID
