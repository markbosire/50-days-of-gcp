#!/bin/bash

# Step 1: Create a custom VPC network
echo "Creating custom VPC network..."
gcloud compute networks create portfolio-network --subnet-mode=custom


echo "Creating subnet in the custom VPC network..."
gcloud compute networks subnets create portfolio-subnet \
    --network=portfolio-network \
    --range=10.0.0.0/24 \
    --region=us-central1

# Step 2: Add firewall rules
echo "Adding firewall rules..."

# Allow HTTP traffic (port 80) from anywhere
gcloud compute firewall-rules create allow-http \
    --network=portfolio-network \
    --allow=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --description="Allow HTTP traffic from anywhere"

# Allow HTTPS traffic (port 443)
gcloud compute firewall-rules create allow-https \
    --network=portfolio-network \
    --allow=tcp:443 \
    --source-ranges=0.0.0.0/0 \
    --description="Allow HTTPS traffic from anywhere"

# Allow SSH traffic (port 22) from anywhere
gcloud compute firewall-rules create allow-ssh \
    --network=portfolio-network \
    --allow=tcp:22 \
    --source-ranges=0.0.0.0/0 \
    --description="Allow SSH traffic from anywhere"

# Step 3: Create and setup VM
echo "Reserving a static IP address..."
gcloud compute addresses create portfolio-static-ip --region=us-central1
STATIC_IP=$(gcloud compute addresses describe portfolio-static-ip --region=us-central1 --format="value(address)")


STARTUP_SCRIPT=$(cat <<'EOF'
#!/bin/bash

# Install Apache HTTP server and SSL module
apt-get update
apt-get install -y apache2 apache2-utils ssl-cert

# Enable required Apache modules
a2enmod ssl
a2enmod headers
a2enmod rewrite

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
        <p class="text-gray-700 mb-4">This is a  portfolio page hosted on Apache</p>
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

echo "Creating VM instance with static IP and startup script..."
gcloud compute instances create portfolio-vm \
    --zone=us-central1-a \
    --machine-type=e2-medium \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --network=portfolio-network \
    --subnet=portfolio-subnet \
    --tags=http-server,https-server \
    --address=$STATIC_IP \
    --metadata=startup-script="${STARTUP_SCRIPT}"

echo "Deployment complete! Your portfolio will be available at:"
echo "http://$STATIC_IP"
# Step 3: Setup  DNS records in your third party Domain Provider and test the domain
echo "Add this to your DNS records in your third party Domain Provider"
