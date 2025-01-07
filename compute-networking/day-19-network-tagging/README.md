
# VPC and Firewall Setup with Connectivity Testing

This script automates the creation of a Virtual Private Cloud (VPC), configures firewall rules, and deploys virtual machine (VM) instances in Google Cloud Platform (GCP). It also includes connectivity tests to validate the setup.

## Features
- Creates a custom VPC and subnet.
- Configures firewall rules to control access between VMs.
- Deploys VMs for different teams (Sales, HR, IT) with startup scripts.
- Tests connectivity between VMs to verify firewall rules.

## Prerequisites
- Google Cloud SDK installed and configured.
- A GCP project with billing enabled.

## Usage
1.  Run the script:
   ```bash
   bash setup_vpc_and_test.sh
   ```
## Clean up

```
gcloud compute instances delete sales-vm --zone=us-central1-a --quiet
gcloud compute instances delete hr-vm --zone=us-central1-a --quiet
gcloud compute instances delete it-vm --zone=us-central1-a --quiet

gcloud compute firewall-rules delete allow-it-to-all-vms --quiet
gcloud compute firewall-rules delete allow-ssh-to-all-vms --quiet
gcloud compute firewall-rules delete allow-hr-sales-to-it-port80 --quiet

gcloud compute networks subnets delete corp-subnet --region=us-central1 --quiet
gcloud compute networks delete corporate-vpc --quiet
```

## What the Script Does
- Creates a VPC named `corporate-vpc` with a custom subnet.
- Sets up firewall rules to allow specific traffic (e.g., SSH, HTTP) between tagged VMs.
- Deploys three VMs (`sales-vm`, `hr-vm`, `it-vm`) with `hping3` installed.
- Tests connectivity between VMs to ensure firewall rules are enforced.


