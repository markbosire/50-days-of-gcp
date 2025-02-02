PROJECT_ID=$(gcloud config get-value project)

# Combine project name with "portfolio" to create the bucket name
BUCKET_NAME="demo-versioning-bucket-${PROJECT_ID}"
TEST_FILE="test-file.txt"
REGION="us-central1"
gcloud storage rm -r gs://${BUCKET_NAME}/${TEST_FILE}
# Delete the bucket
gcloud storage rm -r gs://${BUCKET_NAME}

# Remove local test files
rm ${TEST_FILE}
rm version*_${TEST_FILE}
