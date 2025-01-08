#!/bin/bash

# Enable required APIs
echo "Enabling required APIs..."
gcloud services enable compute.googleapis.com
gcloud services enable deploymentmanager.googleapis.com

# Wait a few seconds for APIs to be fully enabled
echo "Waiting for APIs to be ready..."
sleep 10

# Create YAML file
cat > small-env-vm-config.yaml << 'EOL'
resources:
  # Testing Environment
  - name: test-instance
    type: compute.v1.instance
    properties:
      zone: us-central1-a
      machineType: zones/us-central1-a/machineTypes/e2-micro
      metadata:
        items:
          - key: startup-script
            value: |
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              systemctl start nginx
      disks:
        - deviceName: test-disk
          type: PERSISTENT
          boot: true
          initializeParams:
            sourceImage: projects/debian-cloud/global/images/family/debian-11
      networkInterfaces:
        - network: global/networks/default
          accessConfigs:
            - name: External NAT
              type: ONE_TO_ONE_NAT

  # Staging Environment
  - name: staging-instance
    type: compute.v1.instance
    properties:
      zone: us-central1-a
      machineType: zones/us-central1-a/machineTypes/e2-small
      metadata:
        items:
          - key: startup-script
            value: |
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              systemctl start nginx
      disks:
        - deviceName: staging-disk
          type: PERSISTENT
          boot: true
          initializeParams:
            sourceImage: projects/debian-cloud/global/images/family/debian-11
      networkInterfaces:
        - network: global/networks/default
          accessConfigs:
            - name: External NAT
              type: ONE_TO_ONE_NAT

  # Production Environment
  - name: prod-instance
    type: compute.v1.instance
    properties:
      zone: us-central1-a
      machineType: zones/us-central1-a/machineTypes/e2-medium
      metadata:
        items:
          - key: startup-script
            value: |
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              systemctl start nginx
      disks:
        - deviceName: prod-disk
          type: PERSISTENT
          boot: true
          initializeParams:
            sourceImage: projects/debian-cloud/global/images/family/debian-11
      networkInterfaces:
        - network: global/networks/default
          accessConfigs:
            - name: External NAT
              type: ONE_TO_ONE_NAT
EOL

echo "Creating deployment..."
gcloud deployment-manager deployments create small-company-env --config small-env-vm-config.yaml

echo "Checking deployment status..."
gcloud deployment-manager deployments describe small-company-env

# Describe each instance
echo "Describing test-instance..."
gcloud compute instances describe test-instance --zone=us-central1-a

echo "Describing staging-instance..."
gcloud compute instances describe staging-instance --zone=us-central1-a

echo "Describing prod-instance..."
gcloud compute instances describe prod-instance --zone=us-central1-a

