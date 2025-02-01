#!/bin/bash

# Variables (same as in setup script)
INSTANCE_NAME="test-alloy-instance"
DATABASE_NAME="test_alloy_db"
CLUSTER_NAME="alloydb-cluster"
REGION="us-central1"
ZONE="us-central1-a"
VM_INSTANCE_NAME="postgres-client-vm"
NETWORK_NAME="alloydb-network"
SUBNET_NAME="alloydb-subnet"
NETWORK_TAG="postgres-client"


echo "Starting cleanup of AlloyDB resources..."

# Step 1: Delete the Compute Engine VM instance
echo "Deleting Compute Engine VM instance..."
gcloud compute instances delete $VM_INSTANCE_NAME \
    --zone=$ZONE \
    --quiet


# Step 2: Delete the AlloyDB instance
echo "Deleting AlloyDB instance..."
gcloud alloydb instances delete $INSTANCE_NAME \
    --cluster=$CLUSTER_NAME \
    --region=$REGION \
    --quiet



# Step 3: Delete the AlloyDB cluster
echo "Deleting AlloyDB cluster..."
gcloud alloydb clusters delete $CLUSTER_NAME \
    --region=$REGION \
    --quiet


# Step 4: Remove VPC peering connection
echo "Removing VPC peering connection..."
gcloud services vpc-peerings delete \
    --service=servicenetworking.googleapis.com \
    --network=$NETWORK_NAME \
    --quiet



# Step 5: Delete the reserved IP address range
echo "Deleting reserved IP address range..."
gcloud compute addresses delete servicenetworking-googleapis-com \
    --global \
    --quiet



# Step 6: Delete firewall rules
echo "Deleting firewall rules..."
gcloud compute firewall-rules delete allow-postgres --quiet
gcloud compute firewall-rules delete allow-ssh --quiet



# Step 7: Delete subnet
echo "Deleting subnet..."
gcloud compute networks subnets delete $SUBNET_NAME \
    --region=$REGION \
    --quiet



# Step 8: Delete VPC network
echo "Deleting VPC network..."
gcloud compute networks delete $NETWORK_NAME --quiet

echo "Cleanup completed successfully!"
