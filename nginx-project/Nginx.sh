#!/bin/bash

# Project setup documentation and script to create and manage an Nginx server on GCP.
# Author: Mark Bosire
# Usage: Make sure the gcloud CLI is authenticated and configured to your project.

# Task 1: Create the VM Instance
echo "Creating VM Instance..."
gcloud compute instances create nginx-static-website \
    --zone=us-central1-a \
    --machine-type=e2-micro \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --tags=http-server,https-server

# Task 2: Configure Network Access
echo "Configuring network access (firewall rules)..."
gcloud compute firewall-rules create allow-http \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:80 \
    --target-tags=http-server

gcloud compute firewall-rules create allow-https \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:443 \
    --target-tags=https-server

# Task 3: Connect to the VM
echo "Connecting to VM..."
gcloud compute ssh nginx-static-website --zone=us-central1-a << 'EOF'

# Task 4: Install Nginx
echo "Updating package list and installing Nginx..."
sudo apt update
sudo apt install nginx -y

echo "Starting and enabling Nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

# Task 5: Serve a Static Web Page
echo "Creating custom static webpage..."
echo '<!DOCTYPE html>
<html>
<head>
    <title>100 days of gcp start a web server</title>
</head>
<body>
    <h1>Welcome to the 100 days of gcp page</h1>
    <p>This is a static website hosted on Nginx.</p>
</body>
</html>' | sudo tee /var/www/html/index.html

sudo systemctl restart nginx

EOF

echo "Exiting SSH session..."
echo "Verifying deployment. Fetching external IP..."

# Task 6: Find the external IP
echo "Retrieving external IP..."
EXTERNAL_IP=$(gcloud compute instances list \
    --filter="name=nginx-static-website" \
    --format="get(networkInterfaces[0].accessConfigs[0].natIP)")

echo "Deployment complete. Access your website at http://$EXTERNAL_IP"

echo "To clean up resources, run the following commands:"
echo "gcloud compute instances delete nginx-static-website --zone=us-central1-a --quiet"
echo "gcloud compute firewall-rules delete allow-http --quiet"
echo "gcloud compute firewall-rules delete allow-https --quiet"
