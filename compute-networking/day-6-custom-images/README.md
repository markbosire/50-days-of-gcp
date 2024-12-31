# LAMP Stack Setup on Google Cloud

This script automates the setup of a LAMP (Linux, Apache, MySQL, PHP) stack on Google Cloud Platform, including Redis and monitoring configuration.

## Features

- Configures firewall rules for HTTP and internal database traffic
- Sets up Apache, MySQL, PHP, and Redis
- Configures Google Cloud Ops Agent for monitoring
- Creates a custom VM image
- Includes connection testing

## Prerequisites

- Google Cloud SDK installed and configured
- Appropriate GCP project permissions

## Usage

```bash
./setup-lamp.sh
```

## Cleanup

To remove all created resources, run these commands:

```bash
gcloud compute instances delete lamp-stack-vm lamp-stack-custom-vm --zone=us-central1-a
gcloud compute images delete lamp-stack-custom-image
gcloud compute firewall-rules delete allow-lamp-http allow-internal-database-traffic
```
