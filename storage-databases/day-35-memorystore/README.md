# Redis Setup on Google Cloud Platform

This repository contains a script to automate the setup of a Redis instance on Google Cloud Platform (GCP). The script creates a VPC network, configures firewall rules, launches a Compute Engine VM, and deploys a Redis instance with read replicas.

## Prerequisites

- Google Cloud SDK installed and configured.
- A GCP project with billing enabled.

## Script Overview

The script performs the following tasks:

1. **Enable Required APIs**: Enables the Compute Engine and Redis APIs.
2. **Create a VPC Network**: Sets up a custom VPC network.
3. **Create a Subnet**: Defines a subnet within the VPC.
4. **Configure Firewall Rules**: 
   - Allows SSH access (port 22) from anywhere.
   - Allows internal Redis traffic (port 6379) within the subnet.
5. **Launch a Compute Engine VM**: Creates a VM instance within the VPC and subnet.
6. **Deploy a Redis Instance**: Creates a Redis instance with read replicas.
7. **Connect to Redis**: Connects to the Redis instance from the VM.
8. **Scale Redis**: Updates the Redis instance to increase the number of read replicas.

## Usage

1. Clone the repository or download the `setup_redis.sh` script.
2. Make the script executable:
   ```bash
   chmod +x setup_redis.sh
   ```
3. Run the script:
   ```bash
   ./setup_redis.sh
   ```

## Customization

- Modify the variables at the top of the script to customize the setup (e.g., region, zone, VPC name, subnet range, etc.).
- Adjust the number of read replicas and Redis instance size as needed.

## Notes

- The script includes sleep commands to wait for resource creation. Adjust these as necessary based on your environment.
- Ensure you have the necessary permissions in your GCP project to create and manage resources.

## Cleanup

After testing, remember to delete the resources to avoid incurring charges:
- Delete the Redis instance.
- Delete the VM instance.
- Delete the VPC network and associated firewall rules.

---
