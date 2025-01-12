

# Cloud SQL Replication with Compute Engine VM

This script automates the setup of a **Cloud SQL primary instance**, a **read replica**, and a **Compute Engine VM** to interact with the database. It demonstrates how to:
1. Create a primary Cloud SQL instance and a read replica.
2. Set up a VM with MySQL client installed.
3. Create a database, table, and insert test data into the primary instance.
4. Verify replication by querying the replica instance.

---

## **Prerequisites**
1. **Google Cloud SDK**: Ensure the `gcloud` CLI is installed and configured.
2. **Billing Enabled**: Ensure your Google Cloud project has billing enabled.
3. **Permissions**: Ensure you have the necessary permissions to create Cloud SQL instances, Compute Engine VMs, and firewall rules.

---

## **Script Overview**
The script performs the following steps:
1. Enables necessary APIs (`sqladmin`, `sql-component`, `compute`).
2. Creates a primary Cloud SQL instance.
3. Creates a Compute Engine VM with MySQL client installed.
4. Authorizes the VM to access the primary instance.
5. Creates a database and table on the primary instance.
6. Inserts test data into the primary instance.
7. Creates a read replica of the primary instance.
8. Verifies replication by querying the replica instance.

---

## **Usage**
1. Save the script to a file, e.g., `setup-cloudsql-replication.sh`.
2. Make the script executable:
   ```bash
   chmod +x setup-cloudsql-replication.sh
   ```
3. Run the script:
   ```bash
   ./setup-cloudsql-replication.sh
   ```

---

## **Cleanup**
To avoid incurring charges, delete the resources after testing:
```bash
gcloud sql instances delete replica-db
gcloud sql instances delete primary-db
gcloud compute instances delete mysql-client-vm --zone=us-central1-a
gcloud compute firewall-rules delete allow-mysql-from-vm
```
