# Network Setup Script

This script automates the setup of a network infrastructure on Google Cloud Platform (GCP). It performs the following tasks:

1. **Creates VPCs and Subnets**:
   - Research VPC with two subnets: `data-collection-subnet` and `data-analyst-subnet`.
   - Finance VPC with one subnet: `finance-subnet`.
   - Collaboration VPC with one subnet: `collaboration-subnet`.

2. **Deploys VMs**:
   - `datacollector-vm` in the `data-collection-subnet`.
   - `dataanalyst-vm` in the `data-analyst-subnet`.
   - `finance-vm` in the `finance-subnet`.
   - `collaboration-vm` in the `collaboration-subnet`.

3. **Configures Firewall Rules**:
   - Internal communication within the Research VPC.
   - IAP SSH access for Research, Finance, and Collaboration VPCs.
   - Communication between Collaboration VPC and Research/Finance VPCs.

4. **Establishes VPC Peering**:
   - Between Research VPC and Collaboration VPC.
   - Between Finance VPC and Collaboration VPC.

5. **Tests Connectivity**:
   - Pings between all VMs to ensure proper network setup.

## Usage

Run the script in a GCP environment with the necessary permissions:

```bash
./setup-network.sh
```
## Cleanup
```bash
gcloud compute instances delete datacollector-vm --zone=us-central1-a --quiet
gcloud compute instances delete dataanalyst-vm --zone=us-central1-a --quiet
gcloud compute instances delete finance-vm --zone=us-central1-a --quiet
gcloud compute instances delete collaboration-vm --zone=us-central1-a --quiet

gcloud compute firewall-rules delete research-internal --quiet
gcloud compute firewall-rules delete allow-iap-ssh-research --quiet
gcloud compute firewall-rules delete allow-iap-ssh-finance --quiet
gcloud compute firewall-rules delete allow-iap-ssh-collab --quiet
gcloud compute firewall-rules delete collab-allow-research-finance --quiet

gcloud compute networks peerings delete research-to-collab --network=research-vpc --quiet
gcloud compute networks peerings delete collab-to-research --network=collaboration-vpc --quiet
gcloud compute networks peerings delete finance-to-collab --network=finance-vpc --quiet
gcloud compute networks peerings delete collab-to-finance --network=collaboration-vpc --quiet

gcloud compute networks subnets delete data-collection-subnet --region=us-central1 --quiet
gcloud compute networks subnets delete data-analyst-subnet --region=us-central1 --quiet
gcloud compute networks subnets delete finance-subnet --region=us-central1 --quiet
gcloud compute networks subnets delete collaboration-subnet --region=us-central1 --quiet
```
gcloud compute networks delete research-vpc --quiet
gcloud compute networks delete finance-vpc --quiet
gcloud compute networks delete collaboration-vpc --quiet
