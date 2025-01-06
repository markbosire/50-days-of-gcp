
# Setup Firewall Script

This script sets up a three-tier architecture with a VPC, subnets, firewall rules, and test instances. It also tests connectivity between tiers using `hping3`.

## Usage
1. Run the script:
   ```bash
   ./setup-firewall.sh
   ```
2. Follow the on-screen instructions to set up the VPC, subnets, firewall rules, and test instances.
3. After testing, clean up resources using the provided cleanup commands.

## Cleanup
Run the following commands to delete all resources:
```bash
# Delete Test Instances
gcloud compute instances delete web-tier-test app-tier-test db-tier-test --zone=us-central1-a --quiet

# Delete Firewall Rules
gcloud compute firewall-rules delete block-all-traffic allow-ssh allow-web-tier-from-lb allow-app-tier-from-web allow-db-tier-from-app --quiet

# Delete Subnets
gcloud compute networks subnets delete web-tier-subnet app-tier-subnet db-tier-subnet --region=us-central1 --quiet

# Delete VPC Network
gcloud compute networks delete three-tier-app-vpc --quiet
```

