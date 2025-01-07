#!/bin/bash

PROJECT_ID=$(gcloud config get-value project)
REGION="us-central1"
ZONE="${REGION}-a"

echo "Creating VPCs..."
gcloud compute networks create corporate-vpc --subnet-mode=custom

gcloud compute networks subnets create corp-subnet \
    --network=corporate-vpc \
    --region=${REGION} \
    --range=10.0.1.0/24

echo "Creating Firewall Rules..."


# Allow IT access to all VMs in the VPC (high priority)
gcloud compute firewall-rules create allow-it-to-all-vms \
    --network=corporate-vpc \
    --allow=icmp,tcp:22,tcp:80,tcp:443 \
    --source-tags=it-team

# Allow SSH access to all VMs in the VPC
gcloud compute firewall-rules create allow-ssh-to-all-vms \
    --network=corporate-vpc \
    --allow=tcp:22 \
    --source-ranges=0.0.0.0/0 \
    --description="Allow SSH access to all VMs"
    
# Allow only port 80 access from all other VMs to IT VM (Restrict access)
gcloud compute firewall-rules create allow-hr-sales-to-it-port80 \
    --network=corporate-vpc \
    --allow=tcp:80 \
    --source-tags=hr-team,sales-team \
    --target-tags=it-team 

echo "Creating Instances..."
# Sales VM in the Sales team subnet
gcloud compute instances create sales-vm \
    --zone=${ZONE} \
    --machine-type=e2-micro \
    --subnet=corp-subnet \
    --tags=sales-team \
    --metadata=startup-script='#!/bin/bash
        apt-get update
        apt-get install -y hping3'

# HR VM in the HR team subnet
gcloud compute instances create hr-vm \
    --zone=${ZONE} \
    --machine-type=e2-micro \
    --subnet=corp-subnet \
    --tags=hr-team \
    --metadata=startup-script='#!/bin/bash
        apt-get update
        apt-get install -y hping3'

# IT VM in the IT team subnet
gcloud compute instances create it-vm \
    --zone=${ZONE} \
    --machine-type=e2-micro \
    --subnet=corp-subnet \
    --tags=it-team \
    --metadata=startup-script='#!/bin/bash
        apt-get update
        apt-get install -y hping3'

sleep 20

HR_IP=$(gcloud compute instances describe hr-vm --zone=${ZONE} --format='get(networkInterfaces[0].networkIP)')
SALES_IP=$(gcloud compute instances describe sales-vm --zone=${ZONE} --format='get(networkInterfaces[0].networkIP)')
IT_IP=$(gcloud compute instances describe it-vm --zone=${ZONE} --format='get(networkInterfaces[0].networkIP)')

echo "Test 1: Ping from IT VM to HR VM (Should PASS)"
gcloud compute ssh it-vm --zone=${ZONE} --command="ping -c 3 ${HR_IP}"

echo "Test 2: Ping from Sales VM to HR VM (Should FAIL)"
gcloud compute ssh sales-vm --zone=${ZONE} --command="ping -c 3 ${HR_IP}"

echo "Test 3: SSH from Sales VM to IT VM (Should FaiL)"
gcloud compute ssh sales-vm --zone=${ZONE} --command="ping -c 3 ${HR_IP}"

echo "Test 4: Ping from IT VM to Sales VM (Should PASS)"
gcloud compute ssh it-vm --zone=${ZONE} --command="ping -c 3 ${SALES_IP}"

echo "Test 5: Test connectivity to port 80 on IT VM using hping3(Should PASS)"
gcloud compute ssh sales-vm --zone=${ZONE} --command="sudo hping3 -S -p 80 -c 3 ${IT_IP}"

