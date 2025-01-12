# GCS Signed URL Test Script

This Bash script demonstrates how to create a Google Cloud Storage (GCS) bucket, generate signed URLs, and test their functionality using the `gcloud` command-line tool.

## Features

- Creates a GCS bucket.
- Uploads a test file to the bucket.
- Creates a service account and grants it access to the bucket.
- Generates a signed URL with a short expiration time.
- Tests the signed URL from the local machine before and after expiration.

## Prerequisites

- Google Cloud SDK (`gcloud`) installed and configured.
- A Google Cloud project with billing enabled.

## Usage

1. Clone the repository or copy the script to your local machine.
2. Make the script executable:
   ```bash
   chmod +x script_name.sh
   ```
3. Run the script:
   ```bash
   ./script_name.sh
   ```

## Variables

- `PROJECT_ID`: Automatically retrieves the current project ID.
- `BUCKET_NAME`: Name of the GCS bucket to be created.
- `OBJECT_NAME`: Name of the test file to be uploaded.
- `SERVICE_ACCOUNT`: Name of the service account to be created.
- `EXPIRATION_SHORT`: Expiration time for the signed URL (default: 30 seconds).

## Cleanup

Delete the service account to clean up resources. Replace <PROJECT_ID> with your project ID.
```
gcloud iam service-accounts delete test-signed-url-sa@<PROJECT_ID>.iam.gserviceaccount.com --quiet
```


Delete the GCS bucket and its contents. Replace <UNIQUE_BUCKET_NAME> with your bucket name.

```
gcloud storage rm -r gs://<UNIQUE_BUCKET_NAME> --quiet
```

Delete the local test file.

```
rm -f test-file.txt
```
