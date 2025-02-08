# GCP Predefined Roles Test Script

A bash script to demonstrate and test Google Cloud Platform (GCP) predefined IAM roles using a service account.

## Prerequisites

- Google Cloud SDK installed and configured
- Active GCP project with billing enabled
- Sufficient permissions to create service accounts and assign IAM roles

## Features

The script:
- Creates a new service account
- Assigns multiple predefined roles (Viewer, Logging Viewer, Compute Admin, Service Account User)
- Tests various permissions through practical operations
- Includes cleanup commands for resources created during testing

## Usage

```bash
bash predefined-roles.sh
```

Note: The script includes cleanup commands as comments at the end. Uncomment them to automatically remove the test resources.

## Tests Performed

1. List Compute Engine instances
2. Access Cloud Logging logs
3. Create a Compute Engine instance
4. Attempt to create a service account (expected to fail)
