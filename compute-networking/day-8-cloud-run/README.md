# Network Setup Script

This script automates the setup of a network infrastructure on Google Cloud Platform (GCP). It includes the creation of Virtual Private Clouds (VPCs), subnets, virtual machines (VMs), firewall rules, and VPC peering connections.

## Script Overview

1. **VPC and Subnet Creation**: Creates three VPCs (Research, Finance, Collaboration) with associated subnets.
2. **VM Deployment**: Deploys VMs in each subnet.
3. **Firewall Configuration**: Sets up firewall rules to allow internal communication and SSH access via Identity-Aware Proxy (IAP).
4. **VPC Peering**: Establishes peering connections between the Research, Finance, and Collaboration VPCs.
5. **Connectivity Testing**: Tests connectivity between the deployed VMs using ping.

## Usage

1. Ensure you have the Google Cloud SDK installed and configured.
2. Run the script using
   ```bash
    setup-network.sh```.

## Notes

- Modify the IP ranges and regions as needed.
- Ensure proper IAM permissions are set for the GCP project.

For detailed instructions, refer to the script comments.
