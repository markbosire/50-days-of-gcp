#!/bin/bash

# Set variables
PROJECT_ID=$(gcloud config get-value project)
REGION="us-central1"
ZONE="us-central1-a"

echo "Deploying to project: $PROJECT_ID"

# Error handling
set -e  # Exit on any error
trap 'echo "Error occurred. Exiting..."' ERR

# Task 0: Create Firewall Rule for HTTP traffic
echo "Creating firewall rule for HTTP traffic..."
gcloud compute firewall-rules create allow-http-nginx \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server

# Task 1: Create Instance Template
echo "Creating instance template..."
gcloud compute instance-templates create-with-container nginx-template \
    --region=$REGION \
    --container-image=nginxdemos/hello \
    --tags=http-server  # Add network tag to match firewall rule

# Task 2: Create Managed Instance Group
echo "Creating managed instance group..."
gcloud compute instance-groups managed create nginx-mig \
    --template=nginx-template \
    --size=3 \
    --zone=$ZONE

# Task 3: Configure Autoscaling
echo "Configuring autoscaling..."
gcloud compute instance-groups managed set-autoscaling nginx-mig \
    --max-num-replicas=5 \
    --min-num-replicas=1 \
    --target-cpu-utilization=0.6 \
    --cool-down-period=60 \
    --zone=$ZONE

# Task 4: Deploy Load Balancer Components
echo "Creating health check..."
gcloud compute health-checks create http nginx-health-check \
    --port=80

echo "Creating backend service..."
gcloud compute backend-services create nginx-backend \
    --protocol=HTTP \
    --health-checks=nginx-health-check \
    --global

echo "Adding backend to backend service..."
gcloud compute backend-services add-backend nginx-backend \
    --instance-group=nginx-mig \
    --instance-group-zone=$ZONE \
    --global

echo "Creating URL map..."
gcloud compute url-maps create nginx-map \
    --default-service=nginx-backend

echo "Creating HTTP proxy..."
gcloud compute target-http-proxies create nginx-proxy \
    --url-map=nginx-map

echo "Creating forwarding rule..."
gcloud compute forwarding-rules create nginx-forwarding-rule \
    --global \
    --target-http-proxy=nginx-proxy \
    --ports=80

# Task 5: Get Load Balancer IP
echo "Waiting for load balancer to be ready (30 seconds)..."
sleep 30

echo "Load Balancer IP Address:"
gcloud compute forwarding-rules list --global \
    --filter="name=nginx-forwarding-rule" \
    --format="get(IPAddress)"

# Task 6: Print Monitoring Command
echo -e "\nTo monitor instances, use:"
echo "gcloud compute instance-groups managed list-instances nginx-mig --zone=$ZONE"

# Print Summary
echo -e "\nDeployment Summary:"
echo "- Instance Template: nginx-template"
echo "- Instance Group: nginx-mig"
echo "- Autoscaling: 1-5 instances, 60% CPU target"
echo "- Region: $REGION"
echo "- Zone: $ZONE"
echo "- Firewall Rule: allow-http-nginx (TCP port 80)"
