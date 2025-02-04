# Google OAuth Token Generator

A Bash script for generating OAuth 2.0 access tokens for Google Cloud Platform services using service account credentials.

## Overview

This script automates the process of generating OAuth 2.0 access tokens for Google Cloud Platform (GCP) services using a service account key. It implements the JWT (JSON Web Token) bearer flow to obtain access tokens that can be used to authenticate API requests to Google services.

## Prerequisites

- Bash shell environment
- `jq` command-line JSON processor
- `openssl` for cryptographic operations
- `curl` for making HTTP requests
- A Google Cloud Platform service account key file (JSON format)

## Installation

1. Download the script to your local machine
2. Make it executable:
   ```bash
   chmod +x jwt.sh
   ```

## Usage

```bash
./jwt.sh <path_to_service_account_key.json> <scope>
```

### Parameters

- `path_to_service_account_key.json`: Path to your service account key JSON file
- `scope`: The OAuth scope for which you want to generate the token

### Example

```bash
./generate_token.sh /path/to/service-account.json "https://www.googleapis.com/auth/cloud-platform"
```

## How It Works

1. **Input Validation**
   - Checks for required command-line arguments
   - Validates the service account key file path

2. **JWT Creation**
   - Extracts service account email and private key from the JSON key file
   - Generates JWT header and claim set
   - Creates JWT signature using RS256 algorithm
   - Combines components into a complete JWT

3. **Token Request**
   - Sends JWT to Google's OAuth 2.0 token endpoint
   - Receives and extracts access token from response

## Output

- On success: Prints the access token to stdout
- On failure: Prints an error message with the response from Google's OAuth service

## Security Considerations

- The script creates a temporary file for the private key which is securely deleted after use
- Service account key files should be kept secure and not committed to version control
- Access tokens are valid for 1 hour from generation

## Error Handling

The script includes error handling for common scenarios:
- Missing command-line arguments
- Invalid service account key file
- Failed token requests
- JSON parsing errors

## Dependencies Details

- **jq**: Used for parsing JSON service account key file
  - Version required: 1.5+
  - Installation: Available through most package managers

- **openssl**: Used for creating JWT signature
  - Version required: 1.0.2+
  - Typically pre-installed on most systems

- **curl**: Used for making HTTP requests to Google's OAuth service
  - Version required: 7.0+
  - Typically pre-installed on most systems

## Common Issues and Troubleshooting

1. **"jq: command not found"**
   - Solution: Install jq using your package manager
   - Example: `apt-get install jq` or `brew install jq`

2. **"Permission denied"**
   - Solution: Ensure the script has execute permissions
   - Run: `chmod +x generate_token.sh`

3. **Invalid service account key**
   - Verify the JSON key file is valid and complete
   - Ensure the service account has necessary permissions
