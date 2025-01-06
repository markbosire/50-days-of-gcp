
# VPN Setup Script (`setup_vpn.sh`)

This script automates the setup of a VPN connection between a Cloud VPC and an On-Premises VPC using Google Cloud Platform (GCP). It creates the necessary resources, configures the VPN tunnel, and verifies connectivity.

## Prerequisites
- Google Cloud SDK installed and configured.
- Sufficient permissions to create and manage GCP resources.
- A project set up in GCP.

## Usage
1. Make the script executable:
   ```bash
   chmod +x setup_vpn.sh
   ```
2. Run the script:
   ```bash
   ./setup_vpn.sh
   ```

## What the Script Does
1. **Creates a Cloud VPC and Subnet**:
   - VPC: `cloud-vpc`
   - Subnet: `cloud-subnet` (IP range: `10.1.0.0/16`)

2. **Deploys a Cloud Inventory Management VM**:
   - VM: `cloud-inventory-vm`
   - Zone: `us-central1-a`
   - Machine type: `e2-medium`

3. **Creates an On-Premises VPC and Subnet**:
   - VPC: `onprem-vpc`
   - Subnet: `onprem-subnet` (IP range: `192.168.1.0/24`)

4. **Deploys an On-Premises POS VM**:
   - VM: `onprem-pos-vm`
   - Zone: `us-central1-a`
   - Machine type: `e2-medium`

5. **Reserves a Static IP for the Cloud VPN**.

6. **Creates a Cloud VPN Gateway** and sets up forwarding rules for ESP, UDP 500, and UDP 4500.

7. **Configures a VPN Tunnel** between the Cloud and On-Premises VPCs.

8. **Sets Up Routes** to allow traffic between the two networks.

9. **Configures Firewall Rules** to allow VPN traffic and SSH access.

10. **Installs and Configures the StrongSwan VPN Client** on the On-Premises VM and verifies connectivity.

## Cleanup
To delete all resources created by the script, run the following commands:
```bash
gcloud compute instances delete cloud-inventory-vm --zone=us-central1-a --quiet
gcloud compute instances delete onprem-pos-vm --zone=us-central1-a --quiet
gcloud compute vpn-tunnels delete cloud-vpn-tunnel --region=us-central1 --quiet
gcloud compute forwarding-rules delete esp-rule --region=us-central1 --quiet
gcloud compute forwarding-rules delete udp500-rule --region=us-central1 --quiet
gcloud compute forwarding-rules delete udp4500-rule --region=us-central1 --quiet
gcloud compute target-vpn-gateways delete cloud-vpn-gateway --region=us-central1 --quiet
gcloud compute addresses delete cloud-vpn-ip --region=us-central1 --quiet
gcloud compute firewall-rules delete allow-cloud-vpn-traffic --quiet
gcloud compute firewall-rules delete allow-onprem-vpn-traffic --quiet
gcloud compute firewall-rules delete allow-ssh-from-anywhere --quiet
gcloud compute routes delete cloud-to-onprem --quiet
gcloud compute networks subnets delete cloud-subnet --region=us-central1 --quiet
gcloud compute networks subnets delete onprem-subnet --region=us-central1 --quiet
gcloud compute networks delete cloud-vpc --quiet
gcloud compute networks delete onprem-vpc --quiet
```

