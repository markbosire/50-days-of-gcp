# VPC and VPN Setup Script

This script automates the setup of a multi-region and hybrid cloud interconnectivity environment using Google Cloud Platform (GCP). It creates Virtual Private Clouds (VPCs), subnets, virtual machines (VMs), and configures VPN connectivity between on-premise and cloud environments.

## Features

- **VPC and Subnet Creation**: Creates VPCs and subnets for HQ, Branch, and On-Premise environments.
- **VPC Peering**: Establishes VPC peering between HQ and Branch VPCs.
- **VM Deployment**: Deploys VMs in each environment (HQ, Branch, On-Premise).
- **Cloud VPN Setup**: Configures a Cloud VPN gateway and tunnels for secure connectivity between the cloud and on-premise environments.
- **Firewall Rules**: Configures firewall rules to allow SSH, ICMP, and VPN traffic.
- **VPN Client Installation**: Installs and configures a VPN client on the On-Premise VM.
- **Connectivity Testing**: Tests connectivity between VMs in different environments.

## Prerequisites

- Google Cloud SDK installed and configured.
- A GCP project with billing enabled.
- Sufficient permissions to create and manage GCP resources.

## Usage

1. Ensure you have the Google Cloud SDK installed and authenticated.
2. Clone this repository or download the script.
3. Make the script executable: `chmod +x vpcvpn.sh`.
4. Run the script: `./vpcvpn.sh`.

## Cleanup

```bash
gcloud compute instances delete hq-vm --zone=us-central1-a --quiet
gcloud compute instances delete branch-vm --zone=us-central1-a --quiet
gcloud compute instances delete onprem-vm --zone=us-central1-a --quiet

gcloud compute vpn-tunnels delete cloud-vpn-tunnel --region=us-central1 --quiet

gcloud compute forwarding-rules delete esp-rule --region=us-central1 --quiet
gcloud compute forwarding-rules delete udp500-rule --region=us-central1 --quiet
gcloud compute forwarding-rules delete udp4500-rule --region=us-central1 --quiet

gcloud compute target-vpn-gateways delete cloud-vpn-gateway --region=us-central1 --quiet

gcloud compute addresses delete cloud-vpn-ip --region=us-central1 --quiet

gcloud compute firewall-rules delete allow-ssh-anywhere-hq --quiet
gcloud compute firewall-rules delete allow-ssh-anywhere-branch --quiet
gcloud compute firewall-rules delete allow-ssh-anywhere-onprem --quiet
gcloud compute firewall-rules delete allow-ssh-icmp-hq-to-branch --quiet
gcloud compute firewall-rules delete allow-ssh-icmp-branch-to-hq --quiet
gcloud compute firewall-rules delete allow-hq-vpn-traffic --quiet
gcloud compute firewall-rules delete allow-onprem-vpn-traffic --quiet

gcloud compute routes delete hq-to-onprem --quiet

gcloud compute networks peerings delete hq-to-branch-peering --network=hq-vpc --quiet
gcloud compute networks peerings delete branch-to-hq-peering --network=branch-vpc --quiet

gcloud compute networks subnets delete hq-subnet --region=us-central1 --quiet
gcloud compute networks subnets delete branch-subnet --region=us-central1 --quiet
gcloud compute networks subnets delete onprem-subnet --region=us-central1 --quiet

gcloud compute networks delete hq-vpc --quiet
gcloud compute networks delete branch-vpc --quiet
gcloud compute networks delete onprem-vpc --quiet
```
