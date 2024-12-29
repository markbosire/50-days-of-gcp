#!/bin/bash

# Variables
VPC_NAME="geo-lb-network"
SUBNET_MUMBAI="subnet-asia-south1"
SUBNET_SAOPAULO="subnet-southamerica-east1"
REGION_MUMBAI="asia-south1"
REGION_SAOPAULO="southamerica-east1"
ZONE_MUMBAI="${REGION_MUMBAI}-a"
ZONE_SAOPAULO="${REGION_SAOPAULO}-a"

INSTANCE_TEMPLATE_MUMBAI="instance-template-mumbai"
INSTANCE_TEMPLATE_SAOPAULO="instance-template-saopaulo"
INSTANCE_GROUP_MUMBAI="instance-group-mumbai"
INSTANCE_GROUP_SAOPAULO="instance-group-saopaulo"
FIREWALL_ALLOW_SSH="firewall-allow-ssh"
FIREWALL_ALLOW_HTTP="firewall-allow-http"
FIREWALL_ALLOW_HEALTHCHECK="firewall-allow-healthcheck"
HEALTH_CHECK="http-health-check"
BACKEND_SERVICE="geo-backend-service"
URL_MAP="geo-url-map"
HTTP_PROXY="geo-http-proxy"
FORWARDING_RULE="geo-http-forwarding-rule"

# Create VPC network
echo "Creating VPC network and subnets..."
gcloud compute networks create ${VPC_NAME} --subnet-mode=custom

# Create subnets
gcloud compute networks subnets create ${SUBNET_MUMBAI} \
    --network=${VPC_NAME} \
    --region=${REGION_MUMBAI} \
    --range=10.1.4.0/24

gcloud compute networks subnets create ${SUBNET_SAOPAULO} \
    --network=${VPC_NAME} \
    --region=${REGION_SAOPAULO} \
    --range=10.1.5.0/24

# Create firewall rules
echo "Creating firewall rules..."
gcloud compute firewall-rules create ${FIREWALL_ALLOW_SSH} \
    --network=${VPC_NAME} \
    --direction=INGRESS \
    --action=ALLOW \
    --target-tags=allow-ssh \
    --source-ranges=0.0.0.0/0 \
    --rules=tcp:22

gcloud compute firewall-rules create ${FIREWALL_ALLOW_HTTP} \
    --network=${VPC_NAME} \
    --direction=INGRESS \
    --action=ALLOW \
    --target-tags=load-balanced-backend \
    --source-ranges=0.0.0.0/0 \
    --rules=tcp:80

gcloud compute firewall-rules create ${FIREWALL_ALLOW_HEALTHCHECK} \
    --network=${VPC_NAME} \
    --direction=INGRESS \
    --action=ALLOW \
    --target-tags=load-balanced-backend \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --rules=tcp:80

# Create instance templates
echo "Creating instance templates..."
gcloud compute instance-templates create-with-container ${INSTANCE_TEMPLATE_MUMBAI} \
    --machine-type=e2-medium \
    --network=${VPC_NAME} \
    --subnet=${SUBNET_MUMBAI} \
    --region=${REGION_MUMBAI} \
    --container-image=markbosire/flask-location-tracker \
    --tags=allow-ssh,load-balanced-backend \
    --metadata=startup-script='#!/bin/bash
set -e
echo "Starting container on port 80..."
docker run -d -p 80:5000 markbosire/flask-location-tracker
echo "Container started and accessible on port 80."
'

gcloud compute instance-templates create-with-container ${INSTANCE_TEMPLATE_SAOPAULO} \
    --machine-type=e2-medium \
    --network=${VPC_NAME} \
    --subnet=${SUBNET_SAOPAULO} \
    --region=${REGION_SAOPAULO} \
    --container-image=markbosire/flask-location-tracker \
    --tags=allow-ssh,load-balanced-backend \
    --metadata=startup-script='#!/bin/bash
set -e
echo "Starting container on port 80..."
docker run -d -p 80:5000 markbosire/flask-location-tracker
echo "Container started and accessible on port 80."
'

# Create instance groups
echo "Creating instance groups..."
gcloud compute instance-groups managed create ${INSTANCE_GROUP_MUMBAI} \
    --template=${INSTANCE_TEMPLATE_MUMBAI} \
    --size=2 \
    --zone=${ZONE_MUMBAI}

# Add named port for Mumbai instance group
gcloud compute instance-groups managed set-named-ports ${INSTANCE_GROUP_MUMBAI} \
    --named-ports=http:80 \
    --zone=${ZONE_MUMBAI}

gcloud compute instance-groups managed create ${INSTANCE_GROUP_SAOPAULO} \
    --template=${INSTANCE_TEMPLATE_SAOPAULO} \
    --size=2 \
    --zone=${ZONE_SAOPAULO}

# Add named port for São Paulo instance group
gcloud compute instance-groups managed set-named-ports ${INSTANCE_GROUP_SAOPAULO} \
    --named-ports=http:80 \
    --zone=${ZONE_SAOPAULO}

# Create health check
echo "Setting up load balancer components..."
gcloud compute health-checks create http ${HEALTH_CHECK} \
    --port=80 \
    --check-interval=5s \
    --timeout=5s \
    --healthy-threshold=2 \
    --unhealthy-threshold=2

# Create backend service
gcloud compute backend-services create ${BACKEND_SERVICE} \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=${HEALTH_CHECK} \
    --global

# Add backend instance groups
gcloud compute backend-services add-backend ${BACKEND_SERVICE} \
    --instance-group=${INSTANCE_GROUP_MUMBAI} \
    --instance-group-zone=${ZONE_MUMBAI} \
    --balancing-mode=UTILIZATION \
    --max-utilization=0.8 \
    --capacity-scaler=1.0 \
    --global

gcloud compute backend-services add-backend ${BACKEND_SERVICE} \
    --instance-group=${INSTANCE_GROUP_SAOPAULO} \
    --instance-group-zone=${ZONE_SAOPAULO} \
    --balancing-mode=UTILIZATION \
    --max-utilization=0.8 \
    --capacity-scaler=1.0 \
    --global

# Create URL map
gcloud compute url-maps create ${URL_MAP} \
    --default-service ${BACKEND_SERVICE}

# Create HTTP proxy
gcloud compute target-http-proxies create ${HTTP_PROXY} \
    --url-map=${URL_MAP}

# Create forwarding rule
echo "Creating forwarding rule..."
gcloud compute forwarding-rules create ${FORWARDING_RULE} \
    --load-balancing-scheme=EXTERNAL \
    --network-tier=PREMIUM \
    --address-region=global \
    --target-http-proxy=${HTTP_PROXY} \
    --global \
    --ports=80

# Output load balancer IP
echo -e "\nRetrieving Load Balancer IP Address..."
echo "========================================="
EXTERNAL_IP=$(gcloud compute forwarding-rules describe ${FORWARDING_RULE} --global --format="get(IPAddress)")
echo "External IP: ${EXTERNAL_IP}"

# Get backend health status
echo -e "\nBackend Health Status:"
echo "======================"
gcloud compute backend-services get-health ${BACKEND_SERVICE} \
    --global \
    --format="table(status.healthStatus[].instance.basename(),status.healthStatus[].healthState)"
