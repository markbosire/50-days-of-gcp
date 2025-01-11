# GCP Bucket Lifecycle Management Script

This script automates the creation of a Google Cloud Storage (GCS) bucket and applies a lifecycle management policy to it. The lifecycle policy transitions objects to the `NEARLINE` storage class after 30 days and deletes them after 365 days.

## Prerequisites

- Google Cloud SDK installed and configured.
- A Google Cloud project with billing enabled.

## Usage

1. **Set your project ID** (if not already set):
   ```bash
   gcloud config set project YOUR_PROJECT_ID
   ```

2. **Run the script**:
   ```bash
   bash script_name.sh
   ```

## What the Script Does

- **Creates a GCS Bucket**: The bucket name is prefixed with your project ID (e.g., `YOUR_PROJECT_ID-photos-bucket`).
- **Applies Lifecycle Rules**:
  - Transitions objects to `NEARLINE` storage class after 30 days.
  - Deletes objects after 365 days.
- **Verifies the Lifecycle Policy**: Outputs the lifecycle configuration for the bucket.

## Output

- The script will output the following:
  - Confirmation of bucket creation.
  - Confirmation of lifecycle policy application.
  - JSON-formatted lifecycle configuration for verification.

## Example

```bash
bash script_name.sh
```
