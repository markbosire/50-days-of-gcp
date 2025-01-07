#!/bin/bash

# Variables
PROJECT_ID=$(gcloud config get-value project)
REGION="us-central1"
ZONE="us-central1-a"
HQ_VPC="hq-vpc"
BRANCH_VPC="branch-vpc"
ONPREM_VPC="onprem-vpc"
HQ_SUBNET="hq-subnet"
BRANCH_SUBNET="branch-subnet"
ONPREM_SUBNET="onprem-subnet"
HQ_VM="hq-vm"
BRANCH_VM="branch-vm"
ONPREM_VM="onprem-vm"
HQ_VM_TAG="hq-vm"
BRANCH_VM_TAG="branch-vm"
ONPREM_VM_TAG="onprem-vm"

# Step 1: Create VPCs and Subnets
echo "Creating VPCs and Subnets..."

# HQ VPC and Subnet
gcloud compute networks create $HQ_VPC --subnet-mode=custom
gcloud compute networks subnets create $HQ_SUBNET \
    --network=$HQ_VPC \
    --range=10.0.1.0/24 \
    --region=$REGION

# Branch VPC and Subnet
gcloud compute networks create $BRANCH_VPC --subnet-mode=custom
gcloud compute networks subnets create $BRANCH_SUBNET \
    --network=$BRANCH_VPC \
    --range=10.0.2.0/24 \
    --region=$REGION

# On-Premise VPC and Subnet
gcloud compute networks create $ONPREM_VPC --subnet-mode=custom
gcloud compute networks subnets create $ONPREM_SUBNET \
    --network=$ONPREM_VPC \
    --range=192.168.1.0/24 \
    --region=$REGION

# Step 2: Set Up VPC Peering Between HQ and Branch
echo "Setting up VPC Peering between HQ and Branch..."
gcloud compute networks peerings create hq-to-branch-peering \
    --network=$HQ_VPC \
    --peer-network=$BRANCH_VPC

gcloud compute networks peerings create branch-to-hq-peering \
    --network=$BRANCH_VPC \
    --peer-network=$HQ_VPC

# Step 3: Create VMs in Each Environment
echo "Creating VMs in HQ, Branch, and On-Premise..."

# HQ VM
gcloud compute instances create $HQ_VM \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --subnet=$HQ_SUBNET \
    --tags=$HQ_VM_TAG \
    --image-family=debian-11 \
    --image-project=debian-cloud

# Branch VM
gcloud compute instances create $BRANCH_VM \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --subnet=$BRANCH_SUBNET \
    --tags=$BRANCH_VM_TAG \
    --image-family=debian-11 \
    --image-project=debian-cloud

# On-Premise VM
gcloud compute instances create $ONPREM_VM \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --subnet=$ONPREM_SUBNET \
    --tags=$ONPREM_VM_TAG \
    --image-family=debian-11 \
    --image-project=debian-cloud

# Step 4: Set Up Cloud VPN for On-Premise Connectivity
echo "Setting up Cloud VPN for On-Premise Connectivity..."

# Reserve a Static External IP for the Cloud VPN
gcloud compute addresses create cloud-vpn-ip \
    --region=$REGION
CLOUD_VPN_IP=$(gcloud compute addresses describe cloud-vpn-ip \
    --region=$REGION \
    --format="value(address)")
echo "Cloud VPN IP: $CLOUD_VPN_IP"

# Create the Cloud VPN Gateway
gcloud compute target-vpn-gateways create cloud-vpn-gateway \
    --network=$HQ_VPC \
    --region=$REGION

# Create Forwarding Rules for VPN
gcloud compute forwarding-rules create esp-rule \
    --region=$REGION \
    --ip-protocol=ESP \
    --target-vpn-gateway=cloud-vpn-gateway \
    --address=$CLOUD_VPN_IP

gcloud compute forwarding-rules create udp500-rule \
    --region=$REGION \
    --ip-protocol=UDP \
    --ports=500 \
    --address=$CLOUD_VPN_IP \
    --target-vpn-gateway=cloud-vpn-gateway

gcloud compute forwarding-rules create udp4500-rule \
    --region=$REGION \
    --ip-protocol=UDP \
    --ports=4500 \
    --address=$CLOUD_VPN_IP \
    --target-vpn-gateway=cloud-vpn-gateway

# Fetch On-Premise VM's Public IP
ONPREM_PUBLIC_IP=$(gcloud compute instances describe $ONPREM_VM \
    --zone=$ZONE \
    --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
echo "On-Premise VM Public IP: $ONPREM_PUBLIC_IP"

# Set Up the VPN Tunnel
gcloud compute vpn-tunnels create cloud-vpn-tunnel \
    --region=$REGION \
    --peer-address=$ONPREM_PUBLIC_IP \
    --ike-version=2 \
    --shared-secret=my-vpn-secret \
    --local-traffic-selector=10.0.1.0/24 \
    --remote-traffic-selector=192.168.1.0/24 \
    --target-vpn-gateway=cloud-vpn-gateway

# Step 5: Set Up Routes for VPN
echo "Setting up routes for VPN..."
gcloud compute routes create hq-to-onprem \
    --network=$HQ_VPC \
    --destination-range=192.168.1.0/24 \
    --next-hop-vpn-tunnel=cloud-vpn-tunnel \
    --next-hop-vpn-tunnel-region=$REGION

# Step 6: Configure Firewall Rules
echo "Configuring Firewall Rules..."

# Allow SSH from anywhere to HQ VM
gcloud compute firewall-rules create allow-ssh-anywhere-hq \
    --network=$HQ_VPC \
    --source-ranges=0.0.0.0/0 \
    --allow=tcp:22 \
    --target-tags=$HQ_VM_TAG

# Allow SSH from anywhere to Branch VM
gcloud compute firewall-rules create allow-ssh-anywhere-branch \
    --network=$BRANCH_VPC \
    --source-ranges=0.0.0.0/0 \
    --allow=tcp:22 \
    --target-tags=$BRANCH_VM_TAG

# Allow SSH from anywhere to On-Premise VM
gcloud compute firewall-rules create allow-ssh-anywhere-onprem \
    --network=$ONPREM_VPC \
    --source-ranges=0.0.0.0/0 \
    --allow=tcp:22 \
    --target-tags=$ONPREM_VM_TAG

# Allow SSH and ICMP between HQ and Branch
gcloud compute firewall-rules create allow-ssh-icmp-hq-to-branch \
    --network=$HQ_VPC \
    --source-ranges=10.0.2.0/24 \
    --allow=tcp:22,icmp \
    --target-tags=$HQ_VM_TAG

gcloud compute firewall-rules create allow-ssh-icmp-branch-to-hq \
    --network=$BRANCH_VPC \
    --source-ranges=10.0.1.0/24 \
    --allow=tcp:22,icmp \
    --target-tags=$BRANCH_VM_TAG

# Allow VPN traffic between HQ and On-Premise
gcloud compute firewall-rules create allow-hq-vpn-traffic \
    --network=$HQ_VPC \
    --allow=icmp,tcp,udp \
    --source-ranges=192.168.1.0/24

gcloud compute firewall-rules create allow-onprem-vpn-traffic \
    --network=$ONPREM_VPC \
    --allow=icmp,tcp,udp \
    --target-tags=$ONPREM_VM_TAG \
    --source-ranges=10.0.1.0/24

# Step 7: Install VPN Client on On-Premise VM
echo "Installing VPN Client on On-Premise VM..."
gcloud compute ssh $ONPREM_VM --zone=$ZONE --command="
sudo apt update && 
sudo apt install strongswan -y && 
echo 'config setup
    charondebug=\"ike 2, knl 2, cfg 2\"

conn cloud-vpn
    keyexchange=ikev2
    authby=secret
    left=%defaultroute
    leftid=$ONPREM_PUBLIC_IP
    right=$CLOUD_VPN_IP
    rightsubnet=10.0.1.0/24
    ike=aes256-sha256-modp1024
    esp=aes256-sha256
    auto=start' | sudo tee /etc/ipsec.conf > /dev/null &&

echo \"$ONPREM_PUBLIC_IP $CLOUD_VPN_IP : PSK 'my-vpn-secret'\" | sudo tee /etc/ipsec.secrets > /dev/null &&
sudo ipsec start
"

# Step 8: Add Routes on On-Premise VM
echo "Adding routes on On-Premise VM..."
gcloud compute ssh $ONPREM_VM --zone=$ZONE --command="
sudo ip route add 10.0.1.0/24 via \$(ip route | grep default | awk '{print \$3}')
"

# Step 9: Test Connectivity
echo "Testing Connectivity..."

# Fetch Internal IPs
HQ_VM_IP=$(gcloud compute instances describe $HQ_VM \
    --zone=$ZONE \
    --format="value(networkInterfaces[0].networkIP)")

BRANCH_VM_IP=$(gcloud compute instances describe $BRANCH_VM \
    --zone=$ZONE \
    --format="value(networkInterfaces[0].networkIP)")

# Ping from HQ to Branch
echo "Pinging from HQ VM to Branch VM..."
gcloud compute ssh $HQ_VM \
    --zone=$ZONE \
    --command="ping -c 4 $BRANCH_VM_IP"

# Ping from Branch to HQ
echo "Pinging from Branch VM to HQ VM..."
gcloud compute ssh $BRANCH_VM \
    --zone=$ZONE \
    --command="ping -c 4 $HQ_VM_IP"

# Ping from On-Premise to HQ
echo "Pinging from On-Premise VM to HQ VM..."
gcloud compute ssh $ONPREM_VM --zone=$ZONE --command="
sudo ipsec restart &&
ping -c 4 $HQ_VM_IP
"

echo "Multi-Region and Hybrid Cloud Interconnectivity Setup Complete!"
