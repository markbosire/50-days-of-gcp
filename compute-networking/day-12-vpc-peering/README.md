# VPC Peering Setup Script

This script automates the setup of VPC peering between a **Development VPC** and a **Production VPC** in Google Cloud. It creates the necessary VPCs, subnets, VMs, firewall rules, and VPC peering, and tests connectivity using `ping`.

---

## **Prerequisites**

1. **Google Cloud SDK**: Ensure `gcloud` is installed and configured.
2. **Permissions**: Ensure you have the necessary permissions to create VPCs, subnets, VMs, and firewall rules.

---

## **Script Overview**

The script performs the following steps:

1. **Creates VPCs**:
   - `production-vpc`
   - `development-vpc`

2. **Creates Subnets**:
   - `production-subnet` (10.0.1.0/24)
   - `development-subnet` (10.0.2.0/24)

3. **Creates VMs**:
   - `production-vm` in the Production VPC.
   - `development-vm` in the Development VPC.

4. **Sets Up VPC Peering**:
   - Peers `development-vpc` to `production-vpc` and vice versa.

5. **Configures Firewall Rules**:
   - Allows SSH from anywhere to both VMs.
   - Allows ICMP (ping) from the Development VPC to the Production VPC.

6. **Tests Connectivity**:
   - Pings the `production-vm` from the `development-vm`.

---

## **Usage**

1. **Make the Script Executable**:
   ```bash
   chmod +x setup_vpc_peering.sh
   ```

2. **Run the Script**:
   ```bash
   ./setup_vpc_peering.sh
   ```

---

## **Cleanup**

To delete all resources created by the script, run the following commands:

```bash
# Delete the VMs
gcloud compute instances delete production-vm --zone=us-central1-a --quiet
gcloud compute instances delete development-vm --zone=us-central1-a --quiet

# Delete the Firewall Rules
gcloud compute firewall-rules delete allow-ssh-anywhere-production --quiet
gcloud compute firewall-rules delete allow-ssh-anywhere-development --quiet
gcloud compute firewall-rules delete allow-icmp-dev-to-prod --quiet

# Delete the VPC Peering Connections
gcloud compute networks peerings delete dev-to-prod-peering --network=development-vpc --quiet
gcloud compute networks peerings delete prod-to-dev-peering --network=production-vpc --quiet

# Delete the Subnets
gcloud compute networks subnets delete production-subnet --region=us-central1 --quiet
gcloud compute networks subnets delete development-subnet --region=us-central1 --quiet

# Delete the VPCs
gcloud compute networks delete production-vpc --quiet
gcloud compute networks delete development-vpc --quiet
```

---
