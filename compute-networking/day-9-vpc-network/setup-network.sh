# Task 1: Create VPCs and Subnets
echo "Creating Research VPC and Subnets..."
gcloud compute networks create research-vpc --subnet-mode=custom
gcloud compute networks subnets create data-collection-subnet \
    --network=research-vpc --range=10.1.1.0/24 --region=us-central1
gcloud compute networks subnets create data-analyst-subnet \
    --network=research-vpc --range=10.1.2.0/24 --region=us-central1

echo "Creating Finance VPC and Subnet..."
gcloud compute networks create finance-vpc --subnet-mode=custom
gcloud compute networks subnets create finance-subnet \
    --network=finance-vpc --range=10.2.1.0/24 --region=us-central1

echo "Creating Collaboration VPC and Subnet..."
gcloud compute networks create collaboration-vpc --subnet-mode=custom
gcloud compute networks subnets create collaboration-subnet \
    --network=collaboration-vpc --range=10.3.1.0/24 --region=us-central1

# Task 2: Deploy VMs
echo "Deploying Data Collector VM..."
gcloud compute instances create datacollector-vm \
    --subnet=data-collection-subnet --no-address \
    --metadata=enable-oslogin=true \
    --zone=us-central1-a

echo "Deploying Data Analyst VM..."
gcloud compute instances create dataanalyst-vm \
    --subnet=data-analyst-subnet --no-address \
    --metadata=enable-oslogin=true \
    --zone=us-central1-a

echo "Deploying Finance VM..."
gcloud compute instances create finance-vm \
    --subnet=finance-subnet --no-address \
    --metadata=enable-oslogin=true \
    --zone=us-central1-a

echo "Deploying Collaboration VM..."
gcloud compute instances create collaboration-vm \
    --subnet=collaboration-subnet --no-address \
    --metadata=enable-oslogin=true \
    --zone=us-central1-a

# Task 3: Configure Firewall Rules
echo "Configuring firewall rules for Research VPC..."
gcloud compute firewall-rules create research-internal \
    --network=research-vpc \
    --allow=tcp:22,icmp \
    --source-ranges=10.1.1.0/24,10.1.2.0/24

echo "Allowing IAP SSH access for Research VPC..."
gcloud compute firewall-rules create allow-iap-ssh-research \
    --network=research-vpc \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20

echo "Allowing IAP SSH access for Finance VPC..."
gcloud compute firewall-rules create allow-iap-ssh-finance \
    --network=finance-vpc \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20

echo "Allowing IAP SSH access for Collaboration VPC..."
gcloud compute firewall-rules create allow-iap-ssh-collab \
    --network=collaboration-vpc \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20

echo "Configuring firewall rules for Collaboration VPC..."
gcloud compute firewall-rules create collab-allow-research-finance \
    --network=collaboration-vpc \
    --allow=tcp:22,icmp \
    --source-ranges=10.1.0.0/16,10.2.0.0/16

# Task 4: Establish VPC Peering
echo "Establishing VPC peering between Research VPC and Collaboration VPC..."
gcloud compute networks peerings create research-to-collab \
    --network=research-vpc \
    --peer-network=collaboration-vpc

gcloud compute networks peerings create collab-to-research \
    --network=collaboration-vpc \
    --peer-network=research-vpc

echo "Establishing VPC peering between Finance VPC and Collaboration VPC..."
gcloud compute networks peerings create finance-to-collab \
    --network=finance-vpc \
    --peer-network=collaboration-vpc

gcloud compute networks peerings create collab-to-finance \
    --network=collaboration-vpc \
    --peer-network=finance-vpc

# Task 5: Test Connectivity
# SSH via IAP to test
# Store IPs in variables
DATACOLLECTOR_IP=$(gcloud compute instances describe datacollector-vm --zone=us-central1-a --format='get(networkInterfaces[0].networkIP)')
DATAANALYST_IP=$(gcloud compute instances describe dataanalyst-vm --zone=us-central1-a --format='get(networkInterfaces[0].networkIP)')
FINANCE_IP=$(gcloud compute instances describe finance-vm --zone=us-central1-a --format='get(networkInterfaces[0].networkIP)')
COLLABORATION_IP=$(gcloud compute instances describe collaboration-vm --zone=us-central1-a --format='get(networkInterfaces[0].networkIP)')

# Define the VMs and their respective IP environment variables
declare -A VM_IPS=(
    [datacollector-vm]="${DATACOLLECTOR_IP}"
    [dataanalyst-vm]="${DATAANALYST_IP}"
    [finance-vm]="${FINANCE_IP}"
    [collaboration-vm]="${COLLABORATION_IP}"
)

# Loop through the VMs and test connectivity
for SOURCE_VM in "${!VM_IPS[@]}"; do
    echo "Testing connectivity from ${SOURCE_VM}..."
    gcloud compute ssh ${SOURCE_VM} \
        --zone=us-central1-a \
        --tunnel-through-iap \
        --command="
            $(for TARGET_VM in "${!VM_IPS[@]}"; do
                if [ "${SOURCE_VM}" != "${TARGET_VM}" ]; then
                    echo "echo 'Pinging ${TARGET_VM}:' && ping -c 3 ${VM_IPS[${TARGET_VM}]};"
                fi
            done)
        "
done

