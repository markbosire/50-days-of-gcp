# OAuth Test Script

This script demonstrates how to fetch the IAM (Identity and Access Management) policy for a Google Cloud Platform (GCP) project using OAuth 2.0 authentication. It retrieves an access token, fetches the current project ID, and makes an API call to get the IAM policy details.

## Prerequisites

- **Google Cloud SDK**: Ensure that the `gcloud` CLI tool is installed and configured on your system.
- **Authentication**: You must have authenticated using `gcloud auth application-default login` or have appropriate service account credentials set up.
- **jq**: The script uses `jq` to format the JSON output. Install it using your package manager (e.g., `apt-get install jq` or `brew install jq`).

## Script Overview

The script performs the following steps:

1. **Retrieve an OAuth 2.0 Access Token**:
   - Uses `gcloud auth application-default print-access-token` to get an access token for authentication.

2. **Get the Current Project ID**:
   - Uses `gcloud config get-value project` to fetch the current project ID configured in your environment.

3. **Fetch IAM Policy Details**:
   - Makes a `POST` request to the Google Cloud Resource Manager API using `curl`.
   - Includes the access token in the `Authorization` header.
   - Specifies the project ID in the API URL to fetch the IAM policy.
   - Uses `jq` to format and display the JSON response.

## Usage

1. Save the script to a file, e.g., `oauth_test.sh`.
2. Make the script executable:
   ```bash
   chmod +x oauth_test.sh
   ```
3. Run the script:
   ```bash
   ./oauth_test.sh
   ```

## Example Output

The script will output the IAM policy for the current project in a formatted JSON structure. For example:

```json
{
  "bindings": [
    {
      "role": "roles/owner",
      "members": [
        "user:admin@example.com"
      ]
    }
  ],
  "etag": "BwX1Z2Y3Z4U="
}
```

