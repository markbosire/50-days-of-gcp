#!/bin/bash

# Variables
INSTANCE_NAME="test-alloy-instance"
DATABASE_NAME="test_alloy_db"
TABLE_NAME="customers"
DB_USER="postgres"
DB_PASSWORD="yourpassword"  # Replace with a secure password
REGION="us-central1"
ZONE="us-central1-a"
CLUSTER_NAME="alloydb-cluster"
VM_INSTANCE_NAME="postgres-client-vm"
NETWORK_NAME="alloydb-network"
SUBNET_NAME="alloydb-subnet"
NETWORK_TAG="postgres-client"

# Step 0: Enable necessary APIs
echo "Enabling necessary APIs..."
gcloud services enable alloydb.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable servicenetworking.googleapis.com

# Step 1: Create a custom network and subnet
echo "Creating custom network and subnet..."
gcloud compute networks create $NETWORK_NAME --subnet-mode=custom
gcloud compute networks subnets create $SUBNET_NAME \
    --network=$NETWORK_NAME \
    --region=$REGION \
    --range=10.0.0.0/24

# Step 2: Create firewall rules
echo "Creating firewall rules..."
gcloud compute firewall-rules create allow-postgres \
    --network=$NETWORK_NAME \
    --allow=tcp:5432 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=$NETWORK_TAG

gcloud compute firewall-rules create allow-ssh \
    --network=$NETWORK_NAME \
    --allow=tcp:22 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=$NETWORK_TAG

# Step 3: Create an AlloyDB cluster and instance
echo "Creating AlloyDB cluster and instance..."
gcloud alloydb clusters create $CLUSTER_NAME \
    --region=$REGION \
    --password=$DB_PASSWORD \
    --network=$NETWORK_NAME 
gcloud compute addresses create servicenetworking-googleapis-com \
    --global \
    --purpose=VPC_PEERING \
    --addresses=192.168.0.0 \
    --prefix-length=16 \
    --network=$NETWORK_NAME

gcloud services vpc-peerings connect \
    --service=servicenetworking.googleapis.com \
    --ranges=servicenetworking-googleapis-com \
    --network=$NETWORK_NAME
gcloud alloydb instances create $INSTANCE_NAME \
    --cluster=$CLUSTER_NAME \
    --region=$REGION \
    --instance-type=PRIMARY \
    --cpu-count=2 
    

# Step 4: Create a Compute Engine VM instance
echo "Creating Compute Engine VM instance..."
gcloud compute instances create $VM_INSTANCE_NAME \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --tags=$NETWORK_TAG \
    --network=$NETWORK_NAME \
    --subnet=$SUBNET_NAME \
    --metadata=startup-script="#!/bin/bash
    apt-get update && \
    apt-get install -y postgresql-client"

# Step 5: Wait for the VM to be ready
echo "Waiting for the VM to be ready..."
sleep 50

# Step 6: Get the VM's external IP address
VM_IP=$(gcloud compute instances describe $VM_INSTANCE_NAME --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
echo "VM external IP address: $VM_IP"

# Step 7: Authorize the VM's IP address to access the AlloyDB instance
PRIVATE_IP=$(gcloud alloydb instances describe $INSTANCE_NAME --cluster=$CLUSTER_NAME --region=$REGION --format='get(ipAddress)')

# Step 8: SSH into the VM and run PostgreSQL commands
echo "Connecting to the VM and running PostgreSQL commands..."
gcloud compute ssh $VM_INSTANCE_NAME --zone=$ZONE --command="
    PGPASSWORD=$DB_PASSWORD psql -h $PRIVATE_IP -U $DB_USER -c 'CREATE DATABASE $DATABASE_NAME;'
"

echo "Creating table '$TABLE_NAME' in database '$DATABASE_NAME'..."
gcloud compute ssh $VM_INSTANCE_NAME --zone=$ZONE --command="
    PGPASSWORD=$DB_PASSWORD psql -h $PRIVATE_IP -U $DB_USER -d $DATABASE_NAME -c '
        CREATE TABLE $TABLE_NAME (
            id SERIAL PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            email VARCHAR(255) NOT NULL,
            phone VARCHAR(15),
            total_points INT DEFAULT 0
        );'
"

echo "Inserting test data into table '$TABLE_NAME'..."
SQL_COMMAND="INSERT INTO $TABLE_NAME (name, email, phone, total_points) VALUES
    ('John Doe', 'john.doe@example.com', '123-456-7890', 100),
    ('Jane Smith', 'jane.smith@example.com', '987-654-3210', 200);"

# Execute the command using gcloud compute ssh
gcloud compute ssh "$VM_INSTANCE_NAME" --zone="$ZONE" --command="PGPASSWORD=$DB_PASSWORD psql -h $PRIVATE_IP -U $DB_USER -d $DATABASE_NAME -c \"$SQL_COMMAND\""

echo "Retrieving data from table '$TABLE_NAME' for verification..."
gcloud compute ssh $VM_INSTANCE_NAME --zone=$ZONE --command="
    PGPASSWORD=$DB_PASSWORD psql -h $PRIVATE_IP -U $DB_USER -d $DATABASE_NAME -c 'SELECT * FROM $TABLE_NAME;'
"



