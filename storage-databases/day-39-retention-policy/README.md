
# Google Cloud Storage Retention Policy Demo

This repository contains two scripts to demonstrate and clean up a Google Cloud Storage bucket with a retention policy.

## Scripts

### `retention.sh`
This script demonstrates how to create a Google Cloud Storage bucket, set a retention policy, upload a file, and test the retention policy by attempting to delete the file before and after the retention period expires.

#### Key Steps:
1. Creates a bucket with uniform bucket-level access.
2. Sets a 60-second retention policy for the bucket.
3. Uploads a test file (`test_file.txt`) to the bucket.
4. Attempts to delete the file immediately (fails due to retention policy).
5. Waits for the retention period to expire (65 seconds).
6. Attempts to delete the file again (succeeds after retention period expires).

### `cleanup.sh`
This script cleans up the resources created by `retention.sh`. It checks if the bucket exists, lists and removes all objects in the bucket, and attempts to delete the bucket.

#### Key Steps:
1. Checks if the bucket exists.
2. Lists all objects in the bucket.
3. Attempts to remove all objects in the bucket.
4. Attempts to delete the bucket (fails if objects are still under retention).

## Usage

1. Run `retention.sh` to create the bucket, set the retention policy, and test the file deletion:
   ```bash
   bash retention.sh
   ```

2. Run `cleanup.sh` to clean up the bucket and its contents after the demo:
   ```bash
   bash cleanup.sh
   ```

## Prerequisites
- Google Cloud SDK (`gcloud`) installed and configured.
- A Google Cloud project with billing enabled.

