#!/bin/bash

# Step 1: Create a Custom VPC Network
echo "Step 1: Creating a custom VPC network..."
gcloud compute networks create healthtech-network \
    --subnet-mode=custom \
    --description="Custom VPC for HIPAA-compliant application"
echo "Custom VPC network 'healthtech-network' created."

# Step 2: Create a Subnet with Private Google Access
echo "Step 2: Creating a subnet with Private Google Access..."
gcloud compute networks subnets create healthtech-subnet \
    --network=healthtech-network \
    --region=us-central1 \
    --range=10.0.0.0/24 \
    --enable-private-ip-google-access \
    --description="Subnet with Private Google Access for HIPAA-compliant VM"
echo "Subnet 'healthtech-subnet' created in 'us-central1' with Private Google Access enabled."

# Step 3: Create the Compute Engine VM
echo "Step 3: Creating the Compute Engine VM..."
gcloud compute instances create healthtech-vm \
    --zone=us-central1-a \
    --machine-type=n1-standard-1 \
    --subnet=healthtech-subnet \
    --no-address \
    --tags=iap-access \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --description="HIPAA-compliant VM with no public IP"
echo "VM 'healthtech-vm' created in 'us-central1-a' with no public IP."

# Step 4: Enable Cloud NAT for Outbound Internet Access
echo "Step 4: Enabling Cloud NAT for outbound internet access..."
# Create a Cloud Router
gcloud compute routers create healthtech-router \
    --network=healthtech-network \
    --region=us-central1 \
    --description="Cloud Router for NAT"
echo "Cloud Router 'healthtech-router' created."

# Create Cloud NAT
gcloud compute routers nats create healthtech-nat \
    --router=healthtech-router \
    --region=us-central1 \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips \
    --enable-logging 
echo "Cloud NAT 'healthtech-nat' created for outbound internet access."

# Step 5: Enable Identity-Aware Proxy (IAP)
echo "Step 5: Enabling Identity-Aware Proxy (IAP)..."
gcloud services enable iap.googleapis.com
echo "IAP enabled."

# Step 6: Create the Firewall Rule for SSH Access via IAP
echo "Step 6: Creating firewall rule for SSH access via IAP..."
gcloud compute firewall-rules create allow-iap-ssh \
    --network=healthtech-network \
    --allow tcp:22 \
    --source-ranges=35.235.240.0/20 \
    --target-tags=iap-access \
    --description="Allow SSH traffic via IAP"
echo "Firewall rule 'allow-iap-ssh' created to allow SSH via IAP."

# Step 7: Connect to the VM via IAP and Check for Software Updates
echo "Step 7: Connecting to the VM via IAP and checking for software updates..."
gcloud compute ssh healthtech-vm --zone=us-central1-a --tunnel-through-iap --command "sudo apt update"
echo "Connected to 'healthtech-vm' via IAP and checked for software updates."

# Summary
echo "Summary:"
echo "1. VM 'healthtech-vm' has no public IP and is located in a private subnet."
echo "2. Cloud NAT 'healthtech-nat' provides outbound internet access for updates while keeping the VM secure."
echo "3. IAP allows secure SSH access to the VM, and firewall rule 'allow-iap-ssh' restricts SSH traffic only through IAP."
echo "4. A single command connects to the VM and checks for updates."
echo "Setup complete!"
