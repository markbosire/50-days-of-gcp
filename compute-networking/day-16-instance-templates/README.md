# GlobalShop Deployment Script

This script automates the deployment of a global web application infrastructure across multiple regions using Google Cloud Platform (GCP). It sets up virtual machines (VMs), configures networking, and verifies the deployment.

## Features
- **Instance Template**: Creates a VM template with a pre-configured web server and a simple HTML page.
- **Multi-Region VPCs**: Sets up Virtual Private Cloud (VPC) networks in multiple regions.
- **Firewall Rules**: Configures firewall rules to allow HTTP and SSH traffic.
- **VM Deployment**: Deploys VMs in each region using the instance template.
- **Verification**: Tests HTTP access to ensure the application is running correctly.

## Prerequisites
- **Google Cloud SDK**: Ensure the `gcloud` CLI is installed and configured.
- **Permissions**: The script requires permissions to create VPCs, VMs, firewall rules, and instance templates in GCP.

## Usage
1. Make the script executable:
   ```bash
   chmod +x deploy_globalshop.sh
   ```
2. Run the script:
   ```bash
   ./deploy_globalshop.sh
   ```

## What the Script Does
1. **Creates an Instance Template**: Defines a VM template with a startup script to install and configure a web server.
2. **Sets Up VPCs**: Creates VPC networks in multiple regions with auto subnets.
3. **Configures Firewall Rules**: Allows HTTP (port 80) and SSH (port 22) traffic for the VMs.
4. **Deploys VMs**: Launches VMs in each region using the instance template.
5. **Verifies Deployment**: Tests HTTP access to the VMs to ensure the application is running.

