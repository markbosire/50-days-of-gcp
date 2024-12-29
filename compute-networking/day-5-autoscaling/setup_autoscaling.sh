#!/bin/bash

# Variables
INSTANCE_TEMPLATE="cpu-load-template-worst"
MACHINE_TYPE="e2-micro"  # Worst performing machine type
INSTANCE_GROUP="cpu-load-group-worst"
ZONE="us-central1-a"
FIREWALL_RULE_NAME="allow-ssh"
MAX_REPLICAS=5
MIN_REPLICAS=1
TARGET_CPU_UTILIZATION=0.6
COOL_DOWN_PERIOD=60

# Function to print steps
print_step() {
    echo "➜ $1"
}



# Step 1: Create Instance Template
print_step "Creating instance template with a demanding stress-ng configuration..."
gcloud compute instance-templates create $INSTANCE_TEMPLATE \
    --machine-type=$MACHINE_TYPE \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --metadata=startup-script="#!/bin/bash
apt-get update
apt-get install -y stress-ng cron
echo \"* * * * * root stress-ng --cpu 20 --timeout 45s\" >> /etc/crontab
service cron restart"

# Step 2: Create Managed Instance Group
print_step "Creating managed instance group..."
gcloud compute instance-groups managed create $INSTANCE_GROUP \
    --base-instance-name=cpu-load-instance-worst \
    --template=$INSTANCE_TEMPLATE \
    --size=1 \
    --zone=$ZONE

# Step 3: Enable Autoscaling
print_step "Enabling autoscaling for the instance group..."
gcloud compute instance-groups managed set-autoscaling $INSTANCE_GROUP \
    --max-num-replicas=$MAX_REPLICAS \
    --min-num-replicas=$MIN_REPLICAS \
    --target-cpu-utilization=$TARGET_CPU_UTILIZATION \
    --cool-down-period=$COOL_DOWN_PERIOD \
    --zone=$ZONE

# Step 4: Add SSH Firewall Rule
print_step "Adding firewall rule to allow SSH access..."
gcloud compute firewall-rules create $FIREWALL_RULE_NAME \
    --allow=tcp:22 \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --source-ranges=0.0.0.0/0 \
    --target-tags=$INSTANCE_TEMPLATE

# Step 5: Monitor Autoscaling
print_step "Setup complete! You can monitor autoscaling with the following command:"
echo "watch -n 5 gcloud compute instance-groups managed list-instances $INSTANCE_GROUP --zone=$ZONE"

