#!/bin/bash

# Set project ID and principal
PROJECT_ID=$(gcloud config get-value project)  # Replace with your project ID
INSTANCE_NAME="hypernova-server"
ZONE="us-west1-b"
MACHINE_TYPE="n1-standard-2"
IMAGE_FAMILY="ubuntu-2204-lts"
IMAGE_PROJECT="ubuntu-os-cloud"
STARTUP_SCRIPT="galactic-startup.sh"
PORT="80" # Port for the web server (could be an interstellar app)




# Create the VM instance with the startup script
gcloud compute instances create $INSTANCE_NAME \
    --project=$PROJECT_ID \
    --zone=$ZONE \
    --image-family=$IMAGE_FAMILY \
    --image-project=$IMAGE_PROJECT \
    --machine-type=$MACHINE_TYPE \
    --metadata=startup-script="#!/bin/bash
# Update and install a cosmic web server
apt-get update
apt-get install -y apache2
systemctl start apache2
systemctl enable apache2

# Deploy an interstellar web page
echo '<html><body><h1>Welcome to the Hypernova Server! Exploring the Universe!</h1></body></html>' > /var/www/html/index.html" \
    --tags=space-web-server
    
    
gcloud compute firewall-rules create allow-http \
    --allow tcp:80 \
    --target-tags space-web-server \
    --description "Allow HTTP traffic to port 80" \
    --project $PROJECT_ID


gcloud compute firewall-rules create allow-iap \
    --allow tcp:22,tcp:80 \
    --source-ranges 35.235.240.0/20 \
    --target-tags space-web-server \
    --description "Allow IAP SSH and HTTP" \
    --project $PROJECT_ID
    

    
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="user:$(gcloud config get-value account)" \
    --role=roles/iap.tunnelResourceAccessor

# Wait for the VM to start and IAP to be ready
echo "Preparing the Hypernova Server for interstellar communication..."
sleep 60 # Adjust if necessary for your VM startup time

# Tunnel through IAP to access the cosmic server
echo "Establishing an intergalactic tunnel through IAP..."
gcloud compute start-iap-tunnel $INSTANCE_NAME $PORT \
    --zone $ZONE --project $PROJECT_ID


