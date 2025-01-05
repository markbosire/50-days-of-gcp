# HIPAA-Compliant VM Setup Script

This script automates the setup of a HIPAA-compliant virtual machine (VM) on Google Cloud Platform (GCP). The VM is placed in a private subnet with no public IP, and secure access is provided via Identity-Aware Proxy (IAP). Cloud NAT is configured to allow outbound internet access for updates while maintaining security.

## Steps Included in the Script

1. **Create a Custom VPC Network**: A custom VPC network named `healthtech-network` is created.
2. **Create a Subnet with Private Google Access**: A subnet named `healthtech-subnet` is created within the VPC, with Private Google Access enabled.
3. **Create the Compute Engine VM**: A VM named `healthtech-vm` is created in the private subnet with no public IP.
4. **Enable Cloud NAT for Outbound Internet Access**: Cloud NAT is configured to allow the VM to access the internet for updates.
5. **Enable Identity-Aware Proxy (IAP)**: IAP is enabled to provide secure SSH access to the VM.
6. **Create Firewall Rule for SSH Access via IAP**: A firewall rule is created to allow SSH access only through IAP.
7. **Connect to the VM via IAP and Check for Software Updates**: The script connects to the VM via IAP and checks for software updates.

## Cleanup Commands

To clean up the resources created by this script, run the following commands:

```bash
# Delete the VM
gcloud compute instances delete healthtech-vm --zone=us-central1-a

# Delete the Cloud NAT
gcloud compute routers nats delete healthtech-nat --router=healthtech-router --region=us-central1

# Delete the Cloud Router
gcloud compute routers delete healthtech-router --region=us-central1

# Delete the firewall rule
gcloud compute firewall-rules delete allow-iap-ssh

# Delete the subnet
gcloud compute networks subnets delete healthtech-subnet --region=us-central1

# Delete the VPC network
gcloud compute networks delete healthtech-network
