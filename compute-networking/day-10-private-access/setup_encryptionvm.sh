# Set environment variables
export PROJECT_ID=$(gcloud config get-value project)
export BUCKET_NAME="gs://${PROJECT_ID}-my-encrypted-files"

# 1. Enable required APIs
gcloud services enable \
  compute.googleapis.com \
  storage.googleapis.com \
  iam.googleapis.com \
  identitytoolkit.googleapis.com

# 2. Create VPC network
gcloud compute networks create my-vpc --subnet-mode=custom
gcloud compute networks subnets create my-subnet \
  --network=my-vpc \
  --region=us-central1 \
  --range=10.0.0.0/24 \
  --enable-private-ip-google-access

# 3. Create a service account for the VM
export SERVICE_ACCOUNT_NAME="encryption-vm-sa"
gcloud iam service-accounts create ${SERVICE_ACCOUNT_NAME} \
  --description="Service account for encryption VM" \
  --display-name="Encryption VM Service Account"

# 4. Grant the service account the Storage Admin role
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

# 5. Create VM instance with the service account
gcloud compute instances create encryption-vm \
  --zone=us-central1-a \
  --subnet=my-subnet \
  --no-address \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --service-account=${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com \
  --scopes=https://www.googleapis.com/auth/cloud-platform

# 6. Create Storage bucket
gcloud storage buckets create ${BUCKET_NAME} --location=US

# 7. Add firewall rule for IAP SSH access
gcloud compute firewall-rules create allow-ssh-iap \
  --network=my-vpc \
  --allow=tcp:22 \
  --source-ranges=35.235.240.0/20

# 8. Create and upload test file
echo "MySecurePassword123" > password.txt

# 9. Upload file to VM
sleep 20
gcloud compute scp password.txt encryption-vm:~/password.txt \
  --zone=us-central1-a \
  --tunnel-through-iap

# 10. Upload file to bucket directly from VM
gcloud compute ssh encryption-vm \
  --zone=us-central1-a \
  --tunnel-through-iap \
  --command="gcloud storage cp ~/password.txt ${BUCKET_NAME}/password.txt"

# Additional useful bucket operations:

# List bucket contents
gcloud storage ls ${BUCKET_NAME}

# Download file from bucket
gcloud storage cp ${BUCKET_NAME}/password.txt ./downloaded_password.txt
