#!/bin/bash

# Dynamically retrieve the active Google Cloud project ID
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)

# Bigtable and Compute Engine Details
INSTANCE_ID="weather-instance"
CLUSTER_ID="weather-cluster"
TABLE_ID="weather-data"
ZONE="us-central1-b"
COLUMN_FAMILY="weather"
VM_NAME="bigtable-vm"
VM_ZONE="us-central1-a"
VM_MACHINE_TYPE="e2-medium"

# Step 1: Create a Bigtable instance
echo "Creating Bigtable instance in project: $PROJECT_ID..."
gcloud bigtable instances create "$INSTANCE_ID" \
  --display-name="Weather Bigtable Instance" \
  --cluster-config=id=$CLUSTER_ID,zone=$ZONE,nodes=1 \
  --project="$PROJECT_ID"

# Step 2: Create a Compute Engine instance with a startup script for installations
echo "Creating Compute Engine instance with startup script..."
gcloud compute instances create "$VM_NAME" \
  --zone="$VM_ZONE" \
  --machine-type="$VM_MACHINE_TYPE" \
  --image-family="debian-11" \
  --image-project="debian-cloud" \
  --tags="ssh" \
  --scopes="https://www.googleapis.com/auth/bigtable.data,https://www.googleapis.com/auth/cloud-platform" \
  --metadata=startup-script='#! /bin/bash
    apt-get update -y
    apt-get install -y google-cloud-sdk google-cloud-cli-cbt -y
  '

# Step 3: Add SSH firewall rule
echo "Adding SSH firewall rule..."
gcloud compute firewall-rules create "allow-ssh" \
  --allow=tcp:22 \
  --target-tags="ssh" \
  --description="Allow SSH access"

echo "Waiting for VM to provision..."
sleep 30

# Step 4: Connect to the VM via SSH and set up the Bigtable configuration
echo "Connecting to VM for manual data insertion..."
gcloud compute ssh "$VM_NAME" --zone="$VM_ZONE" --command="
  echo 'Setting up Bigtable configuration...'
  echo 'project = $PROJECT_ID' > ~/.cbtrc
  echo 'instance = $INSTANCE_ID' >> ~/.cbtrc
  echo 'Configuration completed. Creating table and inserting dummy data...'

  # Create the table and column family
  cbt createtable \"$TABLE_ID\" || echo 'Table already exists'
  cbt createfamily \"$TABLE_ID\" \"$COLUMN_FAMILY\" || echo 'Column family already exists'

  # Insert dummy data
  cbt set \"$TABLE_ID\" 'city#2025-01-01T00:00:00Z' \
    \"$COLUMN_FAMILY:temperature=25\" \
    \"$COLUMN_FAMILY:wind_speed=10\"
  cbt set \"$TABLE_ID\" 'city#2025-01-02T00:00:00Z' \
    \"$COLUMN_FAMILY:temperature=22\" \
    \"$COLUMN_FAMILY:wind_speed=12\"
  cbt set \"$TABLE_ID\" 'city#2025-01-03T00:00:00Z' \
    \"$COLUMN_FAMILY:temperature=28\" \
    \"$COLUMN_FAMILY:wind_speed=15\"

  echo 'Dummy data inserted successfully. Querying data...'
  cbt read \"$TABLE_ID\"
"

echo "Setup complete! Bigtable instance created, dummy data inserted, and queried successfully."

