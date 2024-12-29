#!/bin/bash


# Variables
INSTANCE_TEMPLATE="cpu-load-template-worst"
INSTANCE_GROUP="cpu-load-group-worst"
FIREWALL_RULE_NAME="allow-ssh"
ZONE="us-central1-a"

# Function to print steps
print_step() {
    echo "➜ $1"
}


# Step 1: Delete Managed Instance Group
print_step "Deleting managed instance group..."
gcloud compute instance-groups managed delete $INSTANCE_GROUP \
    --zone=$ZONE --quiet

# Step 2: Delete Instance Template
print_step "Deleting instance template..."
gcloud compute instance-templates delete $INSTANCE_TEMPLATE --quiet

# Step 3: Delete Firewall Rule
print_step "Deleting firewall rule..."
gcloud compute firewall-rules delete $FIREWALL_RULE_NAME --quiet

echo "✅ Cleanup complete!"

