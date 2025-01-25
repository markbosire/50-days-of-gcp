#!/bin/bash

# Retrieve the current project ID
PROJECT_ID=$(gcloud config get-value project)
if [ -z "$PROJECT_ID" ]; then
  echo "Error: Unable to retrieve the project ID. Make sure you are authenticated and have a project set."
  exit 1
fi

# Task 1: Configure required resources

# Create a Cloud Storage bucket
BUCKET_NAME="${PROJECT_ID}-kms"
REGION="us-central1"  # Replace with your desired region

echo "Creating Cloud Storage bucket: gs://${BUCKET_NAME}"
gcloud storage buckets create gs://${BUCKET_NAME} --location=${REGION}

# Create sample files
echo "Creating sample files..."
echo "This is sample file 1" > file1.txt
echo "This is sample file 2" > file2.txt
echo "This is sample file 3" > file3.txt

# Upload file1.txt to the bucket
echo "Uploading file1.txt to the bucket..."
gcloud storage cp file1.txt gs://${BUCKET_NAME}/

# Enable Cloud KMS
echo "Enabling Cloud KMS..."
gcloud services enable cloudkms.googleapis.com

# Task 2: Use Cloud KMS

# Create variables for KeyRing and CryptoKey names
KEYRING_NAME="lab-keyring"
CRYPTOKEY_1_NAME="labkey-1"
CRYPTOKEY_2_NAME="labkey-2"

# Create a KeyRing
echo "Creating KeyRing: ${KEYRING_NAME}"
gcloud kms keyrings create ${KEYRING_NAME} --location=${REGION}

# Create CryptoKey 1
echo "Creating CryptoKey: ${CRYPTOKEY_1_NAME}"
gcloud kms keys create ${CRYPTOKEY_1_NAME} --location=${REGION} \
  --keyring=${KEYRING_NAME} --purpose=encryption

# Create CryptoKey 2
echo "Creating CryptoKey: ${CRYPTOKEY_2_NAME}"
gcloud kms keys create ${CRYPTOKEY_2_NAME} --location=${REGION} \
  --keyring=${KEYRING_NAME} --purpose=encryption

# Task 3: Use the default Cloud Storage service account

# Retrieve the default Cloud Storage service account email
DEFAULT_STORAGE_SA="service-$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')@gs-project-accounts.iam.gserviceaccount.com"
echo "Default Cloud Storage service account: ${DEFAULT_STORAGE_SA}"

# Grant permissions to the default Cloud Storage service account
echo "Granting Cloud KMS permissions to the default Cloud Storage service account..."
gcloud kms keys add-iam-policy-binding ${CRYPTOKEY_1_NAME} \
  --location=${REGION} --keyring=${KEYRING_NAME} \
  --condition=None \
  --member=serviceAccount:${DEFAULT_STORAGE_SA} --role=roles/cloudkms.cryptoKeyEncrypterDecrypter

gcloud kms keys add-iam-policy-binding ${CRYPTOKEY_2_NAME} \
  --location=${REGION} --keyring=${KEYRING_NAME} \
  --condition=None \
  --member=serviceAccount:${DEFAULT_STORAGE_SA} --role=roles/cloudkms.cryptoKeyEncrypterDecrypter

# Task 4: Add a default key for the bucket

# Set the default key for the bucket
echo "Setting the default encryption key for the bucket..."
gcloud storage buckets update gs://${BUCKET_NAME} \
  --default-encryption-key=projects/${PROJECT_ID}/locations/${REGION}/keyRings/${KEYRING_NAME}/cryptoKeys/${CRYPTOKEY_1_NAME}

# Verify the default key for the bucket
echo "Verifying the default encryption key for the bucket..."
gcloud storage buckets describe gs://${BUCKET_NAME} --format="value(encryption.defaultKmsKey)"

# Upload file2.txt to the bucket
echo "Uploading file2.txt to the bucket..."
gcloud storage cp file2.txt gs://${BUCKET_NAME}/

# Task 5: Encrypt individual objects with a Cloud KMS key

# Upload file3.txt to the bucket, encrypting it with the second key
echo "Uploading file3.txt to the bucket with custom encryption..."
gcloud storage cp file3.txt gs://${BUCKET_NAME}/ \
  --encryption-key=projects/${PROJECT_ID}/locations/${REGION}/keyRings/${KEYRING_NAME}/cryptoKeys/${CRYPTOKEY_2_NAME}

# Verify the encryption keys used for the files
echo "Verifying encryption keys for the files..."
for FILE in file1.txt file2.txt file3.txt; do
  echo "Details for ${FILE}:"
  gcloud storage objects describe gs://${BUCKET_NAME}/${FILE} --format="value(kmsKey)"
done

echo "Script completed successfully."

