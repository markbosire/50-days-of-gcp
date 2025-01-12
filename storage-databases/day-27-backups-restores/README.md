# Cloud SQL Instance Creation Script

This script automates the creation of a Google Cloud SQL instance with automated backups and retrieves its details.

## Script Overview
1. **Creates a Cloud SQL instance** with the following configuration:
   - Database version: MySQL 8.0
   - Machine type: `db-n1-standard-1`
   - Region: `us-central1`
   - Automated backups start time: `06:00 UTC`

2. **Describes the instance** and displays relevant details in a table format.

## Usage
1. Ensure the Google Cloud SDK (`gcloud`) is installed and configured.
2. Run the script:
   ```bash
   bash create-cloud-sql-instance.sh
   ```

## Output
- The script will create the instance and display its details, including:
  - Instance name
  - Database version
  - Region
  - Machine type
  - Backup configuration status and start time

## Cleanup
To delete the instance after testing, run:
```bash
gcloud sql instances delete my-backup-sql-instance
```

