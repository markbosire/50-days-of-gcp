# GCP Storage Versioning Demo

This repository contains two scripts, `objv.sh` and `cleanup.sh`, that demonstrate how to use Google Cloud Storage (GCS) versioning. The scripts create a bucket, enable versioning, upload multiple versions of a file, list and download specific versions, and clean up the resources afterward.

---

## Files

### 1. `objv.sh`
This script performs the following tasks:
1. **Creates a GCS bucket** with a name based on your Google Cloud project ID.
2. **Enables versioning** on the bucket.
3. **Uploads three versions** of a test file (`test-file.txt`) to the bucket.
4. **Lists all versions** of the file.
5. **Downloads and displays** the content of each version.
6. **Deletes the middle version** of the file to demonstrate version deletion.
7. **Lists versions after deletion** to confirm the deletion.

### 2. `cleanup.sh`
This script cleans up the resources created by `objv.sh`:
1. **Deletes all versions** of the test file from the bucket.
2. **Deletes the bucket** itself.
3. **Removes local test files** (`test-file.txt` and any downloaded versions).

---

## Prerequisites

- **Google Cloud SDK**: Ensure you have the `gcloud` CLI installed and configured.
- **Google Cloud Project**: Set your project ID using `gcloud config set project YOUR_PROJECT_ID`.
- **Permissions**: Ensure you have the necessary permissions to create and manage GCS buckets and objects.

---

## Usage

### Step 1: Run the Demo Script
Execute the `objv.sh` script to create the bucket, upload file versions, and demonstrate versioning:
```bash
bash objv.sh
```

### Step 2: Clean Up Resources
After completing the demo, run the `cleanup.sh` script to delete the bucket and remove local files:
```bash
bash cleanup.sh
```

---

## Key Commands Used

### In `objv.sh`:
- **Create a bucket**:
  ```bash
  gcloud storage buckets create gs://${BUCKET_NAME} --location=${REGION} --uniform-bucket-level-access
  ```
- **Enable versioning**:
  ```bash
  gcloud storage buckets update gs://${BUCKET_NAME} --versioning
  ```
- **Upload files**:
  ```bash
  gcloud storage cp ${TEST_FILE} gs://${BUCKET_NAME}/
  ```
- **List versions**:
  ```bash
  gcloud storage ls -a gs://${BUCKET_NAME}/${TEST_FILE}
  ```
- **Delete a version**:
  ```bash
  gcloud storage rm "$MIDDLE_VERSION"
  ```

### In `cleanup.sh`:
- **Delete all versions of the file**:
  ```bash
  gcloud storage rm -r gs://${BUCKET_NAME}/${TEST_FILE}
  ```
- **Delete the bucket**:
  ```bash
  gcloud storage rm -r gs://${BUCKET_NAME}
  ```
- **Remove local files**:
  ```bash
  rm ${TEST_FILE}
  rm version*_${TEST_FILE}
  ```

