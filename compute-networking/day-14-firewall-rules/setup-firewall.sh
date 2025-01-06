#!/bin/bash

# Step 1: Define Variables
VPC_NETWORK="three-tier-app-vpc"
WEB_SUBNET="web-tier-subnet"
APP_SUBNET="app-tier-subnet"
DB_SUBNET="db-tier-subnet"
ZONE="us-central1-a"
LOAD_BALANCER_IP_RANGE="10.0.4.0/24"  # Placeholder for load balancer IP range

# Step 2: Create VPC Network
echo "Creating VPC network: $VPC_NETWORK..."
gcloud compute networks create $VPC_NETWORK \
    --subnet-mode=custom

echo "Creating subnets for Web, App, and Database tiers..."

# Web Tier Subnet
echo "Creating Web Tier subnet: $WEB_SUBNET..."
gcloud compute networks subnets create $WEB_SUBNET \
    --network=$VPC_NETWORK \
    --range=10.0.1.0/24 \
    --region=us-central1

# App Tier Subnet
echo "Creating App Tier subnet: $APP_SUBNET..."
gcloud compute networks subnets create $APP_SUBNET \
    --network=$VPC_NETWORK \
    --range=10.0.2.0/24 \
    --region=us-central1

# Database Tier Subnet
echo "Creating Database Tier subnet: $DB_SUBNET..."
gcloud compute networks subnets create $DB_SUBNET \
    --network=$VPC_NETWORK \
    --range=10.0.3.0/24 \
    --region=us-central1

echo "Subnets created."

# Step 3: Create Firewall Rules
echo "Creating firewall rules..."

# Low-priority rule to block all traffic by default
echo "Creating low-priority rule to block all traffic..."
gcloud compute firewall-rules create block-all-traffic \
    --network=$VPC_NETWORK \
    --direction=INGRESS \
    --priority=65534 \
    --action=DENY \
    --rules=all \
    --source-ranges=0.0.0.0/0

# Allow SSH access to all instances
echo "Creating SSH firewall rule..."
gcloud compute firewall-rules create allow-ssh \
    --network=$VPC_NETWORK \
    --direction=INGRESS \
    --priority=1000 \
    --action=ALLOW \
    --rules=tcp:22 \
    --source-ranges=0.0.0.0/0

# Web Tier: Allow HTTP/HTTPS from the load balancer (placeholder IP range)
echo "Creating Web Tier firewall rule for load balancer..."
gcloud compute firewall-rules create allow-web-tier-from-lb \
    --network=$VPC_NETWORK \
    --direction=INGRESS \
    --priority=1000 \
    --action=ALLOW \
    --rules=tcp:80,tcp:443 \
    --source-ranges=$LOAD_BALANCER_IP_RANGE \
    --target-tags=web-tier

# App Tier: Allow traffic from Web Tier on port 8080
echo "Creating App Tier firewall rule..."
gcloud compute firewall-rules create allow-app-tier-from-web \
    --network=$VPC_NETWORK \
    --direction=INGRESS \
    --priority=1000 \
    --action=ALLOW \
    --rules=tcp:8080 \
    --source-tags=web-tier \
    --target-tags=app-tier

# Database Tier: Allow traffic from App Tier on port 3306
echo "Creating Database Tier firewall rule..."
gcloud compute firewall-rules create allow-db-tier-from-app \
    --network=$VPC_NETWORK \
    --direction=INGRESS \
    --priority=1000 \
    --action=ALLOW \
    --rules=tcp:3306 \
    --source-tags=app-tier \
    --target-tags=db-tier

echo "Firewall rules created."

# Step 4: Create Test Instances
echo "Creating test instances..."

# Web Tier Instance
echo "Creating Web Tier instance..."
gcloud compute instances create web-tier-test \
    --zone=$ZONE \
    --subnet=$WEB_SUBNET \
    --tags=web-tier \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script="apt-get update && apt-get install -y hping3"

# App Tier Instance
echo "Creating App Tier instance..."
gcloud compute instances create app-tier-test \
    --zone=$ZONE \
    --subnet=$APP_SUBNET \
    --tags=app-tier \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script="apt-get update && apt-get install -y hping3"

# Database Tier Instance
echo "Creating Database Tier instance..."
gcloud compute instances create db-tier-test \
    --zone=$ZONE \
    --subnet=$DB_SUBNET \
    --tags=db-tier \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script="apt-get update && apt-get install -y hping3"

echo "Test instances created."

# Wait for instances to be ready
echo "Waiting for instances to be ready..."
sleep 20

# Step 5: Test Connectivity with hping3
echo "Testing connectivity with hping3..."

# Get internal IPs of the instances
WEB_TIER_IP=$(gcloud compute instances describe web-tier-test --zone=$ZONE --format='get(networkInterfaces[0].networkIP)')
APP_TIER_IP=$(gcloud compute instances describe app-tier-test --zone=$ZONE --format='get(networkInterfaces[0].networkIP)')
DB_TIER_IP=$(gcloud compute instances describe db-tier-test --zone=$ZONE --format='get(networkInterfaces[0].networkIP)')

# Test Web Tier -> App Tier (Port 8080) - Should Allow
echo "Testing Web Tier -> App Tier (Port 8080) - Should Allow..."
gcloud compute ssh web-tier-test --zone=$ZONE --command="sudo hping3 -S -p 8080 -c 1 $APP_TIER_IP | grep -q 'flags=RA' && echo 'PASS: Firewall allows traffic' || echo 'FAIL: Firewall blocks traffic'"

# Test App Tier -> Database Tier (Port 3306) - Should Allow
echo "Testing App Tier -> Database Tier (Port 3306) - Should Allow..."
gcloud compute ssh app-tier-test --zone=$ZONE --command="sudo hping3 -S -p 3306 -c 1 $DB_TIER_IP | grep -q 'flags=RA' && echo 'PASS: Firewall allows traffic' || echo 'FAIL: Firewall blocks traffic'"

# Test Web Tier -> Database Tier (Port 3306) - Should Block
echo "Testing Web Tier -> Database Tier (Port 3306) - Should Block..."
gcloud compute ssh web-tier-test --zone=$ZONE --command="sudo hping3 -S -p 3306 -c 1 $DB_TIER_IP | grep -q 'flags=RA' && echo 'FAIL: Firewall allows traffic' || echo 'PASS: Firewall blocks traffic'"

# Test App Tier -> Web Tier (Port 80) - Should Block (since only LB is allowed)
echo "Testing App Tier -> Web Tier (Port 80) - Should Block..."
gcloud compute ssh app-tier-test --zone=$ZONE --command="sudo hping3 -S -p 80 -c 1 $WEB_TIER_IP | grep -q 'flags=RA' && echo 'FAIL: Firewall allows traffic' || echo 'PASS: Firewall blocks traffic'"

echo "Setup complete."
