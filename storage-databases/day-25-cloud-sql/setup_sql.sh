#!/bin/bash

# Variables
INSTANCE_NAME="loyalty-db"
DATABASE_NAME="loyalty_program"
TABLE_NAME="customers"
DB_USER="root"
DB_PASSWORD="yourpassword"  # Replace with a secure password
REGION="us-central1"
TIER="db-f1-micro"
VM_INSTANCE_NAME="mysql-client-vm"
ZONE="us-central1-a"
NETWORK_TAG="mysql-client"

# Step 0: Enable necessary APIs
echo "Enabling necessary APIs..."
gcloud services enable sqladmin.googleapis.com
gcloud services enable sql-component.googleapis.com
gcloud services enable compute.googleapis.com

# Step 1: Create a Cloud SQL instance
echo "Creating Cloud SQL instance..."
gcloud sql instances create $INSTANCE_NAME \
    --database-version=MYSQL_8_0 \
    --tier=$TIER \
    --region=$REGION \
    --root-password=$DB_PASSWORD

# Step 2: Create a Compute Engine VM instance
echo "Creating Compute Engine VM instance..."
gcloud compute instances create $VM_INSTANCE_NAME \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --tags=$NETWORK_TAG \
    --metadata=startup-script="#!/bin/bash
    # Install MySQL client
    echo 'Installing MySQL client...'
     apt-get update && \
     apt-get install -y mysql-server"

# Step 3: Wait for the VM to be ready
echo "Waiting for the VM to be ready..."
sleep 20

# Step 4: Get the VM's external IP address
VM_IP=$(gcloud compute instances describe $VM_INSTANCE_NAME --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
echo "VM external IP address: $VM_IP"

# Step 5: Authorize the VM's IP address to access the Cloud SQL instance
echo "Authorizing VM's IP address to access Cloud SQL..."
gcloud sql instances patch $INSTANCE_NAME --authorized-networks=$VM_IP --quiet

# Step 6: Create a firewall rule to allow MySQL connections (port 3306) from the VM
echo "Creating firewall rule to allow ssh and mysql connections..."
gcloud compute firewall-rules create allow-mysql-from-vm \
    --direction=EGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:3306,tcp:22 \
    --destination-ranges=0.0.0.0/0 \
    --target-tags=$NETWORK_TAG

# Step 7: SSH into the VM and run the gcloud sql connect command

echo "Connecting to the VM and running MySQL commands..."

echo "Creating database '$DATABASE_NAME'..."
gcloud compute ssh $VM_INSTANCE_NAME --zone=$ZONE --command="
    sudo mysql --host=$CLOUD_SQL_IP --user=$DB_USER --password=$DB_PASSWORD -e 'CREATE DATABASE $DATABASE_NAME;'
"

echo "Creating table '$TABLE_NAME' in database '$DATABASE_NAME'..."
gcloud compute ssh $VM_INSTANCE_NAME --zone=$ZONE --command="
    sudo mysql --host=$CLOUD_SQL_IP --user=$DB_USER --password=$DB_PASSWORD -e 'USE $DATABASE_NAME; CREATE TABLE $TABLE_NAME (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) NOT NULL,
        phone VARCHAR(15),
        total_points INT DEFAULT 0
    );'
"

echo "Inserting test data into table '$TABLE_NAME'..."
gcloud compute ssh $VM_INSTANCE_NAME --zone=$ZONE --command="
    sudo mysql --host=$CLOUD_SQL_IP --user=$DB_USER --password=$DB_PASSWORD -e 'USE $DATABASE_NAME; INSERT INTO $TABLE_NAME (name, email, phone, total_points) VALUES
    (\"John Doe\", \"john.doe@example.com\", \"123-456-7890\", 100),
    (\"Jane Smith\", \"jane.smith@example.com\", \"987-654-3210\", 200);'
"

echo "Retrieving data from table '$TABLE_NAME' for verification..."
gcloud compute ssh $VM_INSTANCE_NAME --zone=$ZONE --command="
    sudo mysql --host=$CLOUD_SQL_IP --user=$DB_USER --password=$DB_PASSWORD -e 'USE $DATABASE_NAME; SELECT * FROM $TABLE_NAME;'
"
echo "Data retrieval attempted."


# Step 8: Clean up (optional)
echo "Script completed. To delete the instance, run:"
echo "gcloud sql instances delete $INSTANCE_NAME"
echo "gcloud compute instances delete $VM_INSTANCE_NAME --zone=$ZONE"
echo "gcloud compute firewall-rules delete allow-mysql-from-vm"
