#!/bin/bash

# Variables
PRIMARY_INSTANCE_NAME="primary-db"
REPLICA_INSTANCE_NAME="replica-db"
DATABASE_NAME="inventory"
TABLE_NAME="products"
DB_USER="root"
DB_PASSWORD="yourpassword"  # Replace with a secure password
REGION="us-central1"
REPLICA_REGION="us-east1"
TIER="db-f1-micro"
VM_INSTANCE_NAME="mysql-client-vm"
ZONE="us-central1-a"
NETWORK_TAG="mysql-client"

# Step 1: Enable necessary APIs
gcloud services enable sqladmin.googleapis.com
gcloud services enable sql-component.googleapis.com
gcloud services enable compute.googleapis.com

# Step 2: Create the primary Cloud SQL instance
gcloud sql instances create $PRIMARY_INSTANCE_NAME \
    --database-version=MYSQL_8_0 \
    --tier=$TIER \
    --region=$REGION \
    --root-password=$DB_PASSWORD

# Step 3: Create a Compute Engine VM instance
gcloud compute instances create $VM_INSTANCE_NAME \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --tags=$NETWORK_TAG \
    --metadata=startup-script="#!/bin/bash
    apt-get update
    apt-get install -y mysql-client"

# Step 4: Wait for the VM to be ready
sleep 120

# Step 5: Get the VM's external IP address
VM_IP=$(gcloud compute instances describe $VM_INSTANCE_NAME --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

# Step 6: Authorize the VM's IP address to access the primary Cloud SQL instance
gcloud sql instances patch $PRIMARY_INSTANCE_NAME --authorized-networks=$VM_IP --quiet

# Step 7: Create a firewall rule to allow MySQL and SSH connections
gcloud compute firewall-rules create allow-mysql-from-vm \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:3306,tcp:22 \
    --target-tags=$NETWORK_TAG

# Step 8: Create a database and table on the primary instance
gcloud compute ssh $VM_INSTANCE_NAME --zone=$ZONE --command="
    mysql --host=$(gcloud sql instances describe $PRIMARY_INSTANCE_NAME --format='value(ipAddresses[0].ipAddress)') --user=$DB_USER --password=$DB_PASSWORD -e 'CREATE DATABASE $DATABASE_NAME;'
"

gcloud compute ssh $VM_INSTANCE_NAME --zone=$ZONE --command="
    mysql --host=$(gcloud sql instances describe $PRIMARY_INSTANCE_NAME --format='value(ipAddresses[0].ipAddress)') --user=$DB_USER --password=$DB_PASSWORD -e 'USE $DATABASE_NAME; CREATE TABLE $TABLE_NAME (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        quantity INT DEFAULT 0
    );'
"

# Step 9: Insert test data into the primary instance
gcloud compute ssh $VM_INSTANCE_NAME --zone=$ZONE --command="
    mysql --host=$(gcloud sql instances describe $PRIMARY_INSTANCE_NAME --format='value(ipAddresses[0].ipAddress)') --user=$DB_USER --password=$DB_PASSWORD -e 'USE $DATABASE_NAME; INSERT INTO $TABLE_NAME (name, quantity) VALUES
    (\"Product A\", 100),
    (\"Product B\", 200);'
"

# Step 10: Create a replica instance
gcloud sql instances create $REPLICA_INSTANCE_NAME \
    --master-instance-name=$PRIMARY_INSTANCE_NAME \
    --region=$REPLICA_REGION \
    --tier=$TIER

# Step 11: Wait for the replica to be ready
sleep 120

# Step 12: Verify replication by querying the replica
gcloud compute ssh $VM_INSTANCE_NAME --zone=$ZONE --command="
    mysql --host=$(gcloud sql instances describe $REPLICA_INSTANCE_NAME --format='value(ipAddresses[0].ipAddress)') --user=$DB_USER --password=$DB_PASSWORD -e 'USE $DATABASE_NAME; SELECT * FROM $TABLE_NAME;'
"

# Step 13: Clean up (optional)
echo "Script completed. To delete the instances, run:"
echo "gcloud sql instances delete $PRIMARY_INSTANCE_NAME"
echo "gcloud sql instances delete $REPLICA_INSTANCE_NAME"
echo "gcloud compute instances delete $VM_INSTANCE_NAME --zone=$ZONE"
echo "gcloud compute firewall-rules delete allow-mysql-from-vm"
