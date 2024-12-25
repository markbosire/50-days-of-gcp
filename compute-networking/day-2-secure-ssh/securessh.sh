#!/bin/bash

# Script to securely set up SSH access to a GCP VM with firewall rules
# Author: [Your Name]
# Date: [Today's Date]

# Task 1: Create the VM Instance
echo "Creating VM Instance with SSH access..."
gcloud compute instances create secure-ssh-vm \
    --zone=us-central1-a \
    --machine-type=e2-micro \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --tags=ssh-server

# Task 2: Identify the Corporate IP Address
echo "Identifying corporate IP address..."
echo "Using ifconfig.me:"
CORPORATE_IP=$(curl -s ifconfig.me)
echo "Corporate IP Address: $CORPORATE_IP"
echo "Using ipinfo.io for verification:"
echo "$(curl -s ipinfo.io/ip)"

# Task 3: Verify Default SSH Access
echo "Testing default SSH access to VM..."
gcloud compute ssh secure-ssh-vm --zone=us-central1-a << 'EOF'
echo "Default SSH access confirmed. Exiting session."
exit
EOF

# Task 4: Review Existing Firewall Rules
echo "Reviewing existing firewall rules for SSH access..."
gcloud compute firewall-rules list --filter="allowed:(tcp:22)"

# Task 5: Create a New Firewall Rule
echo "Creating new firewall rule to restrict SSH access to corporate IP..."
gcloud compute firewall-rules create allow-corporate-ssh \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:22 \
    --source-ranges=${CORPORATE_IP}/32 \
    --target-tags=ssh-server

echo "Disabling default-allow-ssh rule for stricter access control..."
gcloud compute firewall-rules update default-allow-ssh --disabled

# Task 6: Test Restricted Access
echo "Testing SSH access with restricted rule..."
gcloud compute ssh secure-ssh-vm --zone=us-central1-a << 'EOF'
echo "Restricted SSH access confirmed. Exiting session."
exit
EOF

echo "Attempting SSH access from unauthorized IP (requires manual VPN testing)..."
echo "Simulate unauthorized access by connecting to a VPN and re-run the SSH command."
echo "Ensure connection fails to confirm restriction is active."

# Task 7: Document and Share
echo "Documenting SSH access policy..."
cat <<EOL > ssh_access_policy.txt
**Updated SSH Access Policy**
- SSH access to the VM is restricted to the corporate IP: ${CORPORATE_IP}
- Firewall rule: allow-corporate-ssh
- Rule details:
  - Port: 22 (SSH)
  - Source range: ${CORPORATE_IP}/32
  - Target tags: ssh-server

Ensure no other rules unintentionally allow broader access.
EOL

echo "Policy saved to ssh_access_policy.txt. Share this document with your team."
