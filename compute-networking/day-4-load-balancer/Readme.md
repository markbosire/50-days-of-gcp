# Global Load Balancer Setup Script

A bash script to deploy a globally distributed application on Google Cloud Platform (GCP) with load balancing between Mumbai (asia-south1) and São Paulo (southamerica-east1) regions.

## Features
- Creates a custom VPC network with regional subnets
- Deploys containerized applications using instance groups
- Sets up HTTP load balancing with health checks
- Configures firewall rules for SSH, HTTP, and health checks

## Prerequisites
- Google Cloud SDK installed and configured
- Appropriate GCP project permissions


## Usage
```bash
bash globallb.sh
