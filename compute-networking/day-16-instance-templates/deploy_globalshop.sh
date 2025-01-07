#!/bin/bash

# Step 1: Create an Instance Template
echo "Creating instance template..."
STARTUP_SCRIPT=$(cat <<EOF
#!/bin/bash
apt-get update
apt-get install -y apache2
echo "<!DOCTYPE html>
<html>
<head>
    <title>Welcome to GlobalShop</title>
</head>
<body>
    <h1>Welcome to GlobalShop!</h1>
    <p>Your global e-commerce destination.</p>
</body>
</html>" > /var/www/html/index.html
systemctl restart apache2
EOF
)

gcloud compute instance-templates create globalshop-web-template \
    --machine-type=e2-medium \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata-from-file=startup-script=<(echo "$STARTUP_SCRIPT") \
    --tags=http-server

# Step 2: Create VPCs in Three Regions
echo "Creating VPCs in North America, Europe, and Asia..."
gcloud compute networks create globalshop-vpc-us \
    --subnet-mode=auto \
    --bgp-routing-mode=regional

gcloud compute networks create globalshop-vpc-eu \
    --subnet-mode=auto \
    --bgp-routing-mode=regional

gcloud compute networks create globalshop-vpc-asia \
    --subnet-mode=auto \
    --bgp-routing-mode=regional

# Step 3: Create Firewall Rules
echo "Creating firewall rules for HTTP and SSH..."
gcloud compute firewall-rules create allow-http \
    --network=globalshop-vpc-us \
    --allow=tcp:80 \
    --target-tags=http-server

gcloud compute firewall-rules create allow-http-eu \
    --network=globalshop-vpc-eu \
    --allow=tcp:80 \
    --target-tags=http-server

gcloud compute firewall-rules create allow-http-asia \
    --network=globalshop-vpc-asia \
    --allow=tcp:80 \
    --target-tags=http-server

gcloud compute firewall-rules create allow-ssh \
    --network=globalshop-vpc-us \
    --allow=tcp:22

gcloud compute firewall-rules create allow-ssh-eu \
    --network=globalshop-vpc-eu \
    --allow=tcp:22

gcloud compute firewall-rules create allow-ssh-asia \
    --network=globalshop-vpc-asia \
    --allow=tcp:22

# Step 4: Create VMs in Each Region
echo "Creating VMs in North America, Europe, and Asia..."
gcloud compute instances create globalshop-web-us \
    --source-instance-template=globalshop-web-template \
    --zone=us-central1-a \
    --network=globalshop-vpc-us

gcloud compute instances create globalshop-web-eu \
    --source-instance-template=globalshop-web-template \
    --zone=europe-west1-b \
    --network=globalshop-vpc-eu

gcloud compute instances create globalshop-web-asia \
    --source-instance-template=globalshop-web-template \
    --zone=asia-east1-a \
    --network=globalshop-vpc-asia

# Step 5: Wait for VMs to initialize
echo "Waiting for VMs to initialize ..."
sleep 20

# Step 6: Verify Deployment
echo "Retrieving external IPs and testing HTTP access..."

# Get external IPs
US_IP=$(gcloud compute instances describe globalshop-web-us --zone=us-central1-a --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
EU_IP=$(gcloud compute instances describe globalshop-web-eu --zone=europe-west1-b --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
ASIA_IP=$(gcloud compute instances describe globalshop-web-asia --zone=asia-east1-a --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

# Test HTTP access using curl
echo "Testing HTTP access for North America (US):"
curl "http://$US_IP"

echo "Testing HTTP access for Europe (EU):"
curl "http://$EU_IP"

echo "Testing HTTP access for Asia (Asia):"
curl "http://$ASIA_IP"

echo "Deployment and verification complete!"
