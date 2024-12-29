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

echo "Starting cleanup of GCP resources..."

# Delete forwarding rule
echo "Deleting forwarding rule..."
gcloud compute forwarding-rules delete ${FORWARDING_RULE} \
    --global \
    --quiet

# Delete HTTP proxy
echo "Deleting HTTP proxy..."
gcloud compute target-http-proxies delete ${HTTP_PROXY} \
    --quiet

# Delete URL map
echo "Deleting URL map..."
gcloud compute url-maps delete ${URL_MAP} \
    --quiet

# Delete backend service
echo "Deleting backend service..."
gcloud compute backend-services delete ${BACKEND_SERVICE} \
    --global \
    --quiet

# Delete health check
echo "Deleting health check..."
gcloud compute health-checks delete ${HEALTH_CHECK} \
    --quiet

# Delete instance groups
echo "Deleting instance groups..."
gcloud compute instance-groups managed delete ${INSTANCE_GROUP_MUMBAI} \
    --zone=${ZONE_MUMBAI} \
    --quiet

gcloud compute instance-groups managed delete ${INSTANCE_GROUP_SAOPAULO} \
    --zone=${ZONE_SAOPAULO} \
    --quiet

# Delete instance templates
echo "Deleting instance templates..."
gcloud compute instance-templates delete ${INSTANCE_TEMPLATE_MUMBAI} \
    --quiet

gcloud compute instance-templates delete ${INSTANCE_TEMPLATE_SAOPAULO} \
    --quiet

# Delete firewall rules
echo "Deleting firewall rules..."
gcloud compute firewall-rules delete ${FIREWALL_ALLOW_SSH} \
    --quiet

gcloud compute firewall-rules delete ${FIREWALL_ALLOW_HTTP} \
    --quiet

gcloud compute firewall-rules delete ${FIREWALL_ALLOW_HEALTHCHECK} \
    --quiet

# Delete subnets
echo "Deleting subnets..."
gcloud compute networks subnets delete ${SUBNET_MUMBAI} \
    --region=${REGION_MUMBAI} \
    --quiet

gcloud compute networks subnets delete ${SUBNET_SAOPAULO} \
    --region=${REGION_SAOPAULO} \
    --quiet

# Delete VPC network
echo "Deleting VPC network..."
gcloud compute networks delete ${VPC_NAME} \
    --quiet

echo "Cleanup complete!"
