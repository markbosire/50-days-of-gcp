# Loyalty Program Database Setup with Google Cloud SQL

This script automates the setup of a customer loyalty program database using Google Cloud SQL. It creates a MySQL instance, sets up a database and table, inserts test data, and retrieves the data for verification.

## Prerequisites
- Google Cloud SDK (`gcloud`) installed and authenticated.
- Necessary permissions to create and manage Cloud SQL instances.

## Script Overview
The script performs the following steps:
1. **Enables Required APIs**:
   - `sqladmin.googleapis.com`
   - `sql-component.googleapis.com`
2. **Creates a Cloud SQL Instance**:
   - Instance Name: `loyalty-db`
   - Database Version: MySQL 8.0
   - Machine Tier: `db-f1-micro`
   - Region: `us-central1`
   - Root Password: Set a secure password (replace `yourpassword`).
3. **Creates a Database and Table**:
   - Database Name: `loyalty_program`
   - Table Name: `customers`
   - Columns: `id`, `name`, `email`, `phone`, `total_points`
4. **Inserts Test Data**:
   - Adds two sample customer records.
5. **Retrieves and Verifies Data**:
   - Displays the inserted data for verification.
6. **Cleans Up (Optional)**:
   - Deletes the Cloud SQL instance to avoid charges.

## How to Use
1. Replace `yourpassword` in the script with a secure password.
2. Make the script executable:
   ```bash
   chmod +x script_name.sh
   ```
3. Run the script:
   ```bash
   ./script_name.sh
   ```

## Clean Up
To delete the Cloud SQL instance after testing, run:
```bash
gcloud sql instances delete loyalty-db
```
