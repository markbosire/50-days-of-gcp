#!/bin/bash

# Step 1: Configure Firewall Rules
echo "Setting up firewall rules..."
gcloud compute firewall-rules create allow-lamp-http \
    --direction=INGRESS \
    --network=default \
    --action=ALLOW \
    --rules=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=lamp-stack

gcloud compute firewall-rules create allow-internal-database-traffic \
    --direction=INGRESS \
    --network=default \
    --action=ALLOW \
    --rules=tcp:3306,tcp:6379 \
    --source-ranges=10.128.0.0/20 \
    --target-tags=lamp-stack

# Step 2: Create Initial VM
echo "Creating the initial VM..."
gcloud compute instances create lamp-stack-vm \
    --zone=us-central1-a \
    --machine-type=e2-medium \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --tags=lamp-stack
    
echo "Waiting for the VM to initialize..."
sleep 30

# Step 3: SSH into the VM and Install Base Software
echo "Updating system and installing packages..."
gcloud compute ssh lamp-stack-vm --zone=us-central1-a --command="\
    sudo apt-get update && \
    sudo apt-get install -y apache2 mysql-server php libapache2-mod-php php-mysql redis-server php-redis"

# Step 4: Set MySQL Root Password and Secure Installation
echo "Securing MySQL installation..."
gcloud compute ssh lamp-stack-vm --zone=us-central1-a --command="\
    sudo mysqladmin -u root password 'your_root_password' && \
    sudo mysql -u root -p'your_root_password' -e \"DELETE FROM mysql.user WHERE User='';\" && \
    sudo mysql -u root -p'your_root_password' -e \"DROP DATABASE IF EXISTS test;\" && \
    sudo mysql -u root -p'your_root_password' -e \"FLUSH PRIVILEGES;\""

# Step 5: Enable and start services
echo "Enabling and starting services..."
gcloud compute ssh lamp-stack-vm --zone=us-central1-a --command="\
    sudo systemctl enable apache2 mysql redis-server && \
    sudo systemctl start apache2 mysql redis-server"

# Step 6: Create MySQL user and set privileges
echo "Creating MySQL user and setting privileges..."
gcloud compute ssh lamp-stack-vm --zone=us-central1-a --command="\
    echo \"CREATE USER 'your_username'@'localhost' IDENTIFIED BY 'your_password'; \
          GRANT ALL PRIVILEGES ON *.* TO 'your_username'@'localhost' WITH GRANT OPTION; \
          FLUSH PRIVILEGES;\" | sudo mysql -u root -p'your_root_password'"

# Step 7: Install and Configure Google Cloud Ops Agent
echo "Downloading and adding Google Cloud Ops Agent repository..."
gcloud compute ssh lamp-stack-vm --zone=us-central1-a --command="\
    curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh && \
    sudo bash add-google-cloud-ops-agent-repo.sh --also-install"

echo "Configuring the Google Cloud Ops Agent..."
gcloud compute ssh lamp-stack-vm --zone=us-central1-a --command="\
    sudo tee /etc/google-cloud-ops-agent/config.yaml <<EOF
logging:
  receivers:
    apache-access:
      type: files
      include_paths:
        - /var/log/apache2/access.log
    apache-error:
      type: files
      include_paths:
        - /var/log/apache2/error.log
    mysql-logs:
      type: files
      include_paths:
        - /var/log/mysql/error.log
    redis-logs:
      type: files
      include_paths:
        - /var/log/redis/redis-server.log
  service:
    pipelines:
      default_pipeline:
        receivers: [apache-access, apache-error, mysql-logs, redis-logs]
EOF"

echo "Restarting the Google Cloud Ops Agent service..."
gcloud compute ssh lamp-stack-vm --zone=us-central1-a --command="\
    sudo systemctl restart google-cloud-ops-agent"

# Step 8: Test PHP Connections
echo "Testing PHP connections..."
gcloud compute ssh lamp-stack-vm --zone=us-central1-a --command="\
    sudo tee /var/www/html/test_connection.php <<EOF
<?php
\\\$redis = new Redis();
\\\$redis->connect('127.0.0.1', 6379);
if (\\\$redis->ping()) {
    echo \"Redis is working!<br>\";
} else {
    echo \"Redis is not working.<br>\";
}
\\\$mysqli = new mysqli('localhost', 'your_username', 'your_password', 'mysql');
if (\\\$mysqli->connect_error) {
    echo \"MySQL connection failed: \" . \\\$mysqli->connect_error . \"<br>\";
} else {
    echo \"MySQL is working!<br>\";
}
?>
EOF
    exit
"

# Step 9: Create a Custom VM Image
echo "Creating a custom VM image..."
gcloud compute instances stop lamp-stack-vm --zone=us-central1-a
gcloud compute images create lamp-stack-custom-image \
    --source-disk=lamp-stack-vm \
    --source-disk-zone=us-central1-a

# Step 10: Verify Project ID
echo "Verifying project ID..."
gcloud config list project

# Step 11: Create VM from Custom Image
echo "Creating VM from custom image..."
gcloud compute instances create lamp-stack-custom-vm \
    --zone=us-central1-a \
    --machine-type=e2-medium \
    --image=lamp-stack-custom-image \
    --image-project=$(gcloud config get-value project) \
    --tags=lamp-stack

# Step 12: Output the VM's External IP
echo "Retrieving the VM's external IP..."
gcloud compute instances describe lamp-stack-custom-vm \
    --zone=us-central1-a \
    --format='get(networkInterfaces[0].accessConfigs[0].natIP)'

# Cleanup Commands
echo "To clean up resources, run the following commands:"
echo "gcloud compute instances delete lamp-stack-vm lamp-stack-custom-vm --zone=us-central1-a"
echo "gcloud compute images delete lamp-stack-custom-image"
echo "gcloud compute firewall-rules delete allow-lamp-http allow-internal-database-traffic"

