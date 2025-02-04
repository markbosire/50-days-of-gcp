# GCP Service Account Scripts

Simple bash scripts for managing a service account with Google Cloud Platform (GCP) Compute API access.

## Scripts

- `serviceaccount.sh`: Creates a service account, generates key, and tests Compute API access
- `cleanup.sh`: Removes the service account, keys, and cleans up resources

## Prerequisites

- Google Cloud SDK installed
- Authenticated gcloud session
- `jq` command-line tool for JSON processing

## Usage

1. Run the setup:
```bash
bash serviceaccount.sh
```

2. When finished, clean up:
```bash
bash cleanup.sh
```
## JWT DOCS

Understand the JWT code here [JWT Docs](/jwt-docs/README.md)  
