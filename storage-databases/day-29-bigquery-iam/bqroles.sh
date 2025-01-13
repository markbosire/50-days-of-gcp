#!/bin/bash

# Retrieve the default project ID from gcloud configuration
PROJECT_ID=$(gcloud config list --format='value(core.project)')
echo "Getting project ID..."
echo "Using project ID: $PROJECT_ID"

# Get the current user email
USER_EMAIL=$(gcloud config get-value account)
echo "Getting user email..."
echo "Current user: $USER_EMAIL"

# Variables
DATA_ENGINEERING_SA="data-engineering-sa"
DATA_SCIENCE_SA="data-science-sa"
DATASET_NAME="demo_dataset"

# Step 1: Create Dataset
echo "Creating dataset ${DATASET_NAME}..."
bq mk --dataset "${PROJECT_ID}:${DATASET_NAME}"

# Create sample table with initial data
echo "Creating sample table with test data..."
bq query --use_legacy_sql=false << EOF
CREATE OR REPLACE TABLE \`${PROJECT_ID}.${DATASET_NAME}.sample_data\`
AS SELECT 
  GENERATE_UUID() as id,
  CONCAT('Product ', CAST(ROW_NUMBER() OVER() AS STRING)) as product_name,
  ROUND(RAND() * 1000, 2) as price,
  CURRENT_TIMESTAMP() as created_at
FROM UNNEST(GENERATE_ARRAY(1, 10));
EOF

# Step 2: Create Service Accounts
echo "Creating Service Accounts..."
gcloud iam service-accounts create $DATA_ENGINEERING_SA --display-name="Data Engineering Service Account"

gcloud iam service-accounts create $DATA_SCIENCE_SA --display-name="Data Science Service Account"

# Step 3: Grant Token Creator role to user for service accounts
echo "Granting Token Creator role to user for service accounts"
gcloud iam service-accounts add-iam-policy-binding \
  "${DATA_ENGINEERING_SA}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --member="user:${USER_EMAIL}" \
  --role="roles/iam.serviceAccountTokenCreator"


gcloud iam service-accounts add-iam-policy-binding \
  "${DATA_SCIENCE_SA}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --member="user:${USER_EMAIL}" \
  --role="roles/iam.serviceAccountTokenCreator"

# Wait for IAM permissions to propagate
echo "[INFO] Waiting 60 seconds for IAM permissions to propagate..."
sleep 60

# Step 4: Assign Roles to Service Accounts
echo " Assigning BigQuery roles..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${DATA_ENGINEERING_SA}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/bigquery.dataEditor" \
  --condition=None


gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${DATA_SCIENCE_SA}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/bigquery.dataViewer" \
  --condition=None

# Step 5: Test Service Accounts
echo "=== Testing Data Engineering Service Account Permissions ==="

gcloud config set auth/impersonate_service_account "${DATA_ENGINEERING_SA}@${PROJECT_ID}.iam.gserviceaccount.com"

# Test write permissions
echo "[SHOULD PASS] Testing write permissions for Data Engineering SA - inserting new row..."
echo '{"id": "'$(cat /proc/sys/kernel/random/uuid)'", "product_name": "test product", "price": 123.45, "created_at": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"}' | bq insert ${PROJECT_ID}:${DATASET_NAME}.sample_data

# Verify the new row
echo "[SHOULD PASS] Testing read permissions for Data Engineering SA - verifying inserted data..."
bq head --max_rows=5 --start_row=6 ${PROJECT_ID}:${DATASET_NAME}.sample_data

echo "=== Testing Data Science Service Account Permissions ==="

gcloud config set auth/impersonate_service_account "${DATA_SCIENCE_SA}@${PROJECT_ID}.iam.gserviceaccount.com"
# Test write permissions (should fail)
echo "[SHOULD FAIL] Testing write permissions for Data Science SA (expected to fail - no write access)..."
echo '{"id": "'$(cat /proc/sys/kernel/random/uuid)'", "product_name": "test product 2", "price": 263.45, "created_at": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"}' | bq insert ${PROJECT_ID}:${DATASET_NAME}.sample_data

# Test read permissions
echo "[SHOULD PASS] Testing read permissions for Data Science SA..."
bq head --max_rows=5 --start_row=7 ${PROJECT_ID}:${DATASET_NAME}.sample_data



# Reset impersonation

gcloud config unset auth/impersonate_service_account

echo "Setup and testing completed!"
echo "Summary of expected results:"
echo "- Data Engineering SA: Should have successfully read and written data"
echo "- Data Science SA: Should have successfully read data but failed to write data"
