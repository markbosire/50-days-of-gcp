#!/bin/bash

# Variables
INSTANCE_NAME="my-backup-sql-instance"
DATABASE_VERSION="MYSQL_8_0"
TIER="db-n1-standard-1"
REGION="us-central1"
BACKUP_START_TIME="06:00"  # Time in UTC

# Create the Cloud SQL instance with automated backups
echo "Creating Cloud SQL instance '$INSTANCE_NAME'..."
gcloud sql instances create $INSTANCE_NAME \
    --database-version=$DATABASE_VERSION \
    --tier=$TIER \
    --region=$REGION \
    --backup-start-time=$BACKUP_START_TIME



# Describe the instance and extract relevant information
echo "Instance details:"
gcloud sql instances describe $INSTANCE_NAME \
    --format="table(name, databaseVersion, region, settings.tier, settings.backupConfiguration.enabled, settings.backupConfiguration.startTime)"


