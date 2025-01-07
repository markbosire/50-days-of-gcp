#!/bin/bash

# Define the domain name
DOMAIN="markbosire.click"

# Enable necessary Google Cloud APIs
echo "Enabling necessary Google Cloud APIs..."
gcloud services enable compute.googleapis.com
gcloud services enable dns.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com

# Step 1: Create a custom VPC network
echo "Creating custom VPC network..."
gcloud compute networks create portfolio-vpc --subnet-mode=custom

echo "Creating subnet in the custom VPC network..."
gcloud compute networks subnets create portfolio-subnet \
    --network=portfolio-vpc \
    --range=10.0.0.0/24 \
    --region=us-central1

# Step 2: Add firewall rules
echo "Adding firewall rules..."

# Allow HTTP traffic (port 80) from anywhere
gcloud compute firewall-rules create portfolio-allow-http \
    --network=portfolio-vpc \
    --allow=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --description="Allow HTTP traffic from anywhere"

# Allow HTTPS traffic (port 443) from anywhere
gcloud compute firewall-rules create portfolio-allow-https \
    --network=portfolio-vpc \
    --allow=tcp:443 \
    --source-ranges=0.0.0.0/0 \
    --description="Allow HTTPS traffic from anywhere"

# Allow SSH traffic (port 22) from anywhere
gcloud compute firewall-rules create portfolio-allow-ssh \
    --network=portfolio-vpc \
    --allow=tcp:22 \
    --source-ranges=0.0.0.0/0 \
    --description="Allow SSH traffic from anywhere"

# Step 3: Reserve a static IP address for the load balancer
echo "Reserving a static IP address for the load balancer..."
gcloud compute addresses create portfolio-lb-ip --global
LOAD_BALANCER_IP=$(gcloud compute addresses describe portfolio-lb-ip --global --format="value(address)")

# Step 4: Create a Google Cloud DNS Zone
echo "Creating Google Cloud DNS Zone..."
gcloud dns managed-zones create portfolio-dns-zone \
    --dns-name=$DOMAIN. \
    --description="DNS zone for portfolio" \
    --visibility=public

# Retrieve the nameservers for the DNS zone
NAMESERVERS=$(gcloud dns managed-zones describe portfolio-dns-zone --format="value(nameServers)")

# Step 5: Create a DNS A Record pointing to the load balancer IP
echo "Creating DNS A Record..."
gcloud dns record-sets create $DOMAIN. \
    --zone=portfolio-dns-zone \
    --type=A \
    --ttl=300 \
    --rrdatas=$LOAD_BALANCER_IP

# Step 6: Create a Google-managed SSL certificate
echo "Creating Google-managed SSL certificate..."
gcloud compute ssl-certificates create portfolio-ssl-cert \
    --domains=$DOMAIN \
    --global

# Step 7: Create and setup VM
STARTUP_SCRIPT=$(cat <<'EOF'
#!/bin/bash

# Install Apache HTTP server
apt-get update
apt-get install -y apache2

# Create the HTML file
cat > /var/www/html/index.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Portfolio</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 flex items-center justify-center min-h-screen p-4">
    <div class="bg-white p-8 rounded-lg shadow-lg text-center max-w-2xl w-full">
        <h1 class="text-4xl font-bold text-blue-600 mb-4">Welcome to My Portfolio</h1>
        <p class="text-gray-700 mb-4">Hello! I'm a cloud engineering intern showcasing my skills.</p>
        <p class="text-gray-700 mb-4">This is a portfolio page hosted on Apache</p>
        <p class="text-gray-700 mb-6">Feel free to explore and get in touch!</p>
        <a href="mailto:example@example.com" class="inline-block bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition duration-300">
            Contact Me
        </a>
    </div>
</body>
</html>
HTMLEOF

# Set proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Ensure Apache starts on boot and restart the service
systemctl enable apache2
systemctl restart apache2
EOF
)

echo "Creating VM instance..."
gcloud compute instances create portfolio-vm \
    --zone=us-central1-a \
    --machine-type=e2-medium \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --network=portfolio-vpc \
    --subnet=portfolio-subnet \
    --tags=http-server \
    --metadata=startup-script="${STARTUP_SCRIPT}"

# Step 8: Create an unmanaged instance group
echo "Creating unmanaged instance group..."
gcloud compute instance-groups unmanaged create portfolio-instance-group \
    --zone=us-central1-a

# Add the VM to the unmanaged instance group
echo "Adding VM to the unmanaged instance group..."
gcloud compute instance-groups unmanaged add-instances portfolio-instance-group \
    --instances=portfolio-vm \
    --zone=us-central1-a

# Step 9: Set named ports for the instance group
echo "Setting named ports for the instance group..."
gcloud compute instance-groups unmanaged set-named-ports portfolio-instance-group \
    --named-ports=http:80 \
    --zone=us-central1-a

# Step 10: Create a health check for the load balancer
echo "Creating health check..."
gcloud compute health-checks create http portfolio-health-check \
    --port=80

# Step 11: Create a backend service
echo "Creating backend service..."
gcloud compute backend-services create portfolio-backend-service \
    --protocol=HTTP \
    --health-checks=portfolio-health-check \
    --global

# Add the instance group to the backend service
echo "Adding instance group to the backend service..."
gcloud compute backend-services add-backend portfolio-backend-service \
    --instance-group=portfolio-instance-group \
    --instance-group-zone=us-central1-a \
    --global

# Step 12: Create a URL map for the load balancer
echo "Creating URL map..."
gcloud compute url-maps create portfolio-url-map \
    --default-service=portfolio-backend-service

# Step 13: Create a target HTTPS proxy
echo "Creating target HTTPS proxy..."
gcloud compute target-https-proxies create portfolio-https-proxy \
    --url-map=portfolio-url-map \
    --ssl-certificates=portfolio-ssl-cert

# Step 14: Create a global forwarding rule
echo "Creating global forwarding rule..."
gcloud compute forwarding-rules create portfolio-https-forwarding-rule \
    --target-https-proxy=portfolio-https-proxy \
    --ports=443 \
    --address=$LOAD_BALANCER_IP \
    --global

echo "Deployment complete! Your portfolio will be available at:"
echo "http://$LOAD_BALANCER_IP"

# Print the DNS records and nameservers
echo "DNS records have been created:"
echo "--------------------------------"
echo "Domain: $DOMAIN"
echo "Type: A"
echo "TTL: 300"
echo "IP: $LOAD_BALANCER_IP"
echo "--------------------------------"
echo "Nameservers to configure at your domain registrar:"
for ns in $NAMESERVERS; do
    echo "- $ns"
done
echo "--------------------------------"
