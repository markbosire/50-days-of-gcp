#!/bin/bash

# Set variables
PROJECT_ID=$(gcloud config get-value project)

# Combine project name with "portfolio" to create the bucket name
BUCKET_NAME="demo-versioning-bucket-${PROJECT_ID}"
TEST_FILE="test-file.txt"
REGION="us-central1"

echo "Starting GCP Storage versioning demo..."

# Create a new bucket
echo "Creating bucket..."
gcloud storage buckets create gs://${BUCKET_NAME} \
    --location=${REGION} \
    --uniform-bucket-level-access

# Enable versioning on the bucket
echo "Enabling versioning..."
gcloud storage buckets update gs://${BUCKET_NAME} --versioning

# Verify versioning is enabled
echo "Verifying versioning status..."
gcloud storage buckets describe gs://${BUCKET_NAME} \
    --format="get(versioning.enabled)"

# Create and upload initial version of the file
echo "Creating and uploading initial version..."
echo "Version 1 content" > ${TEST_FILE}
gcloud storage cp ${TEST_FILE} gs://${BUCKET_NAME}/

# Create and upload second version
echo "Uploading second version..."
echo "Version 2 content" > ${TEST_FILE}
gcloud storage cp ${TEST_FILE} gs://${BUCKET_NAME}/

# Create and upload third version
echo "Uploading third version..."
echo "Version 3 content" > ${TEST_FILE}
gcloud storage cp ${TEST_FILE} gs://${BUCKET_NAME}/

# List all versions of the object
echo "Listing all versions of the object..."
gcloud storage ls -a gs://${BUCKET_NAME}/${TEST_FILE}

# Download specific versions
echo "Downloading and displaying different versions..."

# Get the version IDs
VERSIONS=$(gcloud storage ls -a gs://${BUCKET_NAME}/${TEST_FILE} | awk '{print $1}')
VERSION_COUNT=1

# Loop through each version and display its content
for VERSION in $VERSIONS; do
    echo "Content of Version $VERSION_COUNT:"
    gcloud storage cp $VERSION version${VERSION_COUNT}_${TEST_FILE}
    cat version${VERSION_COUNT}_${TEST_FILE}
    echo "----------------------------------------"
    VERSION_COUNT=$((VERSION_COUNT + 1))
done

# Demonstrate version deletion (delete the middle version)
echo "Demonstrating version deletion..."
MIDDLE_VERSION=$(echo "$VERSIONS" | sed -n '2p')
gcloud storage rm "$MIDDLE_VERSION"

echo "Listing versions after deletion..."
gcloud storage ls -a gs://${BUCKET_NAME}/${TEST_FILE}

# Clean up
echo "Clean up..."
# Delete all versions of the object
#gcloud storage rm -r gs://${BUCKET_NAME}/${TEST_FILE}
# Delete the bucket
#gcloud storage rm -r gs://${BUCKET_NAME}

# Remove local test files
#rm ${TEST_FILE}
#rm version*_${TEST_FILE}

echo "Demo completed!"
