# Watermark Setup Script

This script automates the setup of a Google Cloud Function that adds a watermark to images uploaded to a Cloud Storage bucket.

## Script Overview

1. **Enable APIs**: Enables necessary Google Cloud APIs.
2. **Service Account**: Creates and configures a service account for the Cloud Function.
3. **Cloud Storage**: Creates a bucket and grants necessary permissions.
4. **Cloud Function**: Sets up and deploys a Python-based Cloud Function to watermark images.
5. **Testing**: Uploads a test image to the bucket and verifies the watermarking process.

## Usage

1. Ensure you have the Google Cloud SDK installed and configured.
2. Run the script using `bash setup_watermark.sh`.
