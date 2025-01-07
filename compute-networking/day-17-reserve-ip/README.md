
# Deploy Portfolio Website on Google Cloud Platform (GCP)

This script automates the deployment of a portfolio website on Google Cloud Platform (GCP). It sets up a custom VPC network, configures firewall rules, reserves a static IP address, and deploys a virtual machine (VM) with Apache web server to host the portfolio.

## Prerequisites

1. **Google Cloud SDK**: Ensure the Google Cloud SDK is installed and configured on your machine.
2. **GCP Project**: You must have an active GCP project with billing enabled.
3. **Permissions**: Ensure you have the necessary permissions to create VPC networks, firewall rules, and VM instances in your GCP project.

## Usage

1. **Make the Script Executable**:
   ```bash
   chmod +x deploy_portfolio.sh
   ```

3. **Run the Script**:
   ```bash
   ./deploy_portfolio.sh
   ```

## What the Script Does

1. **Creates a Custom VPC Network**:  
   - Sets up a custom VPC network with a subnet for isolated resource management.

2. **Configures Firewall Rules**:  
   - Allows HTTP (port 80), HTTPS (port 443), and SSH (port 22) traffic.

3. **Reserves a Static IP Address**:  
   - Reserves a static IP address for the VM to ensure consistent access.

4. **Deploys a VM Instance**:  
   - Creates a VM with a Debian-based OS, assigns it to the custom VPC and subnet, and runs a startup script to:
     - Install and configure Apache web server.
     - Deploy a basic portfolio HTML page.
     - Enable necessary Apache modules and restart the service.

5. **Outputs the Static IP**:  
   - After deployment, the script outputs the static IP address where the portfolio website will be accessible.

## Custom Domain Setup

If you have a custom domain, add an **A record** in your DNS provider to map the domain to the static IP address provided by the script.

## Access the Portfolio

Once the script completes, your portfolio website will be accessible at:
```
http://<static-ip>
```

## Cleanup

```
gcloud compute instances delete portfolio-vm --zone=us-central1-a --quiet
gcloud compute addresses delete portfolio-static-ip --region=us-central1 --quiet
gcloud compute firewall-rules delete allow-http --quiet
gcloud compute firewall-rules delete allow-ssh --quiet
gcloud compute networks subnets delete portfolio-subnet --region=us-central1 --quiet
gcloud compute networks delete portfolio-network --quiet
```
