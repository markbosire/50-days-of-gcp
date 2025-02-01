#!/bin/bash

# Set your preferred zone, instance name, and disk name
ZONE="us-central1-a"  # Change this as needed
INSTANCE_NAME="my-vm-instance"  # New instance name
DISK_NAME="my-persistent-disk"  # New disk name

# Task 1: Create a new Compute Engine VM instance
echo "Creating VM instance '$INSTANCE_NAME' in zone $ZONE..."
gcloud compute instances create $INSTANCE_NAME \
  --zone $ZONE \
  --machine-type e2-standard-2
echo "VM '$INSTANCE_NAME' is pprovisioning"
sleep 25
echo "VM '$INSTANCE_NAME' created successfully."

# Task 2: Create a new persistent disk
echo "Creating persistent disk '$DISK_NAME' (200GB) in zone $ZONE..."
gcloud compute disks create $DISK_NAME \
  --size=200GB \
  --zone $ZONE

echo "Disk '$DISK_NAME' created successfully."

# Task 3: Attach the disk to the VM
echo "Attaching disk '$DISK_NAME' to VM '$INSTANCE_NAME'..."
gcloud compute instances attach-disk $INSTANCE_NAME \
  --disk $DISK_NAME \
  --zone $ZONE

echo "Disk '$DISK_NAME' attached to VM '$INSTANCE_NAME' successfully."

# Display the final status
echo "Fetching instance details..."
gcloud compute instances describe $INSTANCE_NAME --zone $ZONE --format='json(name,disks[].diskSizeGb,disks[].deviceName,disks[].type,disks[].mode,disks[].boot)'

echo "All tasks completed successfully!"
