#!/bin/bash

# Step 1: Create the Cloud VPC
echo "Creating Cloud VPC..."
gcloud compute networks create cloud-vpc --subnet-mode=custom
gcloud compute networks subnets create cloud-subnet \
  --network=cloud-vpc \
  --region=us-central1 \
  --range=10.1.0.0/16

# Step 2: Deploy the Cloud Inventory Management VM
echo "Deploying Cloud Inventory VM..."
gcloud compute instances create cloud-inventory-vm \
  --zone=us-central1-a \
  --machine-type=e2-medium \
  --subnet=cloud-subnet \
  --no-address
CLOUD_VM_INTERNAL_IP=$(gcloud compute instances describe cloud-inventory-vm \
  --zone=us-central1-a \
  --format="value(networkInterfaces[0].networkIP)")
echo "Cloud VM Internal IP: $CLOUD_VM_INTERNAL_IP"

# Step 3: Create the On-Premises VPC
echo "Creating On-Premises VPC..."
gcloud compute networks create onprem-vpc --subnet-mode=custom
gcloud compute networks subnets create onprem-subnet \
  --network=onprem-vpc \
  --region=us-central1 \
  --range=192.168.1.0/24

# Step 4: Deploy the On-Premises POS VM
echo "Deploying On-Premises POS VM..."
gcloud compute instances create onprem-pos-vm \
  --zone=us-central1-a \
  --machine-type=e2-medium \
  --subnet=onprem-subnet \
  --tags=allow-vpn
ONPREM_PUBLIC_IP=$(gcloud compute instances describe onprem-pos-vm \
  --zone=us-central1-a \
  --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
echo "On-Premises VM Public IP: $ONPREM_PUBLIC_IP"
# Step 5: Reserve a Static External IP for the Cloud VPN
echo "Reserving Static IP for Cloud VPN..."
gcloud compute addresses create cloud-vpn-ip \
  --region=us-central1
CLOUD_VPN_IP=$(gcloud compute addresses describe cloud-vpn-ip \
  --region=us-central1 \
  --format="value(address)")
echo "Cloud VPN IP: $CLOUD_VPN_IP"

# Step 6: Create the Cloud VPN Gateway
echo "Creating Cloud VPN Gateway..."
gcloud compute target-vpn-gateways create cloud-vpn-gateway \
  --network=cloud-vpc \
  --region=us-central1
  
gcloud compute forwarding-rules create esp-rule \
    --region=us-central1 \
    --ip-protocol=ESP \
    --target-vpn-gateway=cloud-vpn-gateway \
    --address=$CLOUD_VPN_IP
    
gcloud compute forwarding-rules create udp500-rule \
  --region=us-central1 \
  --ip-protocol=UDP \
  --ports=500 \
  --address=$CLOUD_VPN_IP \
  --target-vpn-gateway=cloud-vpn-gateway

gcloud compute forwarding-rules create udp4500-rule \
  --region=us-central1 \
  --ip-protocol=UDP \
  --ports=4500 \
  --address=$CLOUD_VPN_IP \
  --target-vpn-gateway=cloud-vpn-gateway

# Step 7: Set Up the VPN Tunnel
echo "Setting up VPN Tunnel..."
gcloud compute vpn-tunnels create cloud-vpn-tunnel \
  --region=us-central1 \
  --peer-address=$ONPREM_PUBLIC_IP \
  --ike-version=2 \
  --shared-secret=my-vpn-secret \
  --local-traffic-selector=10.1.0.0/16 \
  --remote-traffic-selector=192.168.1.0/24 \
  --target-vpn-gateway=cloud-vpn-gateway
 # Step 8: Set Up routes
echo "Setting up routes..." 
gcloud compute routes create cloud-to-onprem \
  --network=cloud-vpc \
  --destination-range=192.168.1.0/24 \
  --next-hop-vpn-tunnel=cloud-vpn-tunnel \
  --next-hop-vpn-tunnel-region=us-central1

# Step 8: Configure Firewall Rules
echo "Configuring Firewall Rules..."
gcloud compute firewall-rules create allow-cloud-vpn-traffic \
  --network=cloud-vpc \
  --allow=icmp,tcp,udp \
  --source-ranges=192.168.1.0/24
gcloud compute firewall-rules create allow-onprem-vpn-traffic \
  --network=onprem-vpc \
  --allow=icmp,tcp,udp \
  --target-tags=allow-vpn \
  --source-ranges=10.1.0.0/16
gcloud compute firewall-rules create allow-ssh-from-anywhere \
  --network=onprem-vpc \
  --allow=tcp:22 \
  --source-ranges=0.0.0.0/0

# Step 9: Install VPN Client and Verify Connectivity
echo "Installing VPN Client and Verifying Connectivity..."
gcloud compute ssh onprem-pos-vm --zone=us-central1-a --command="
sudo apt update && 
sudo apt install strongswan -y && 
echo 'config setup
    charondebug=\"ike 2, knl 2, cfg 2\"

conn cloud-vpn
    keyexchange=ikev2
    authby=secret
    left=%defaultroute
    leftid=$ONPREM_PUBLIC_IP
    right=$CLOUD_VPN_IP
    rightsubnet=10.1.0.0/16
    ike=aes256-sha256-modp1024
    esp=aes256-sha256
    auto=start' | sudo tee /etc/ipsec.conf > /dev/null &&

echo \"$ONPREM_PUBLIC_IP $CLOUD_VPN_IP : PSK 'my-vpn-secret'\" | sudo tee /etc/ipsec.secrets > /dev/null &&
sudo ipsec start
"
echo "Adding routes.."
gcloud compute ssh onprem-pos-vm --zone=us-central1-a --command='
sudo ipsec restart &&
sudo ip route add 10.1.0.0/16 via $(ip route | grep default | awk '"'"'{print $3}'"'"')
'
echo "Verifying Connectivity..."
gcloud compute ssh onprem-pos-vm --zone=us-central1-a --command="
sudo ipsec restart &&
ping -c 4 $CLOUD_VM_INTERNAL_IP
"

echo "Setup Complete!"

