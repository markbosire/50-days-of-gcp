
# IAM Conditional Access Testing Scripts

A set of scripts to demonstrate and test Google Cloud Storage IAM conditional access controls.

## Overview
- `iampolicy.sh`: Creates a test environment and demonstrates the difference between unrestricted and conditional IAM access to Cloud Storage objects
- `cleanup.sh`: Removes all resources created during testing

## Prerequisites
- Google Cloud CLI installed and configured
- Sufficient permissions to create buckets, service accounts, and manage IAM policies

## Usage
1. Run the test script:
```bash
chmod +x iampolicy.sh
./iampolicy.sh
```

2. Clean up resources after testing:
```bash
chmod +x cleanup.sh
./cleanup.sh
```

## What It Does
- Creates a storage bucket with test files in public and confidential directories
- Sets up a service account and tests access with and without IAM conditions
- Demonstrates how to restrict access to specific paths using IAM conditions

## Note
Allow sufficient time for IAM policy changes to propagate between tests.
