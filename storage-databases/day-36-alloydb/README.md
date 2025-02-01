# AlloyDB Setup and Testing Script

This script automates the setup and testing of Google Cloud's **AlloyDB**, a fully managed PostgreSQL-compatible database service. It creates a custom VPC network, sets up an AlloyDB cluster and instance, configures a Compute Engine VM as a PostgreSQL client, and performs basic database operations to test the setup.

## Prerequisites
- A Google Cloud project with billing enabled.
- The `gcloud` CLI installed and configured on your local machine.
- Sufficient permissions to enable APIs, create resources, and manage IAM roles in the project.

## Script Overview
The script performs the following steps:

1. **Enable Necessary APIs**: Enables the AlloyDB, Compute Engine, and Service Networking APIs.
2. **Create a Custom Network and Subnet**: Sets up a VPC network (`alloydb-network`) and a subnet (`alloydb-subnet`).
3. **Create Firewall Rules**: Configures firewall rules to allow PostgreSQL (port 5432) and SSH (port 22) traffic.
4. **Create AlloyDB Cluster and Instance**: Creates an AlloyDB cluster (`alloydb-cluster`) and a primary instance (`test-alloy-instance`).
5. **Create a Compute Engine VM**: Sets up a VM (`postgres-client-vm`) with PostgreSQL client tools installed.
6. **Test Database Operations**: Connects to the AlloyDB instance from the VM, creates a database (`test_alloy_db`), a table (`customers`), inserts test data, and retrieves the data for verification.

## Usage
1. Clone this repository or download the `alloydb.sh` script.
2. Replace the placeholder values (e.g., `yourpassword`) in the script with your desired configurations.
3. Make the script executable:
   ```bash
   chmod +x alloydb.sh
   ```
4. Run the script:
   ```bash
   ./alloydb.sh
   ```

## Cleanup


1. Make the script executable:
   ```bash
   chmod +x cleanup.sh
   ```
2. Run the script:
   ```bash
   ./cleanup.sh
   ```
