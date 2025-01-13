# E-commerce Cloud Spanner Setup Script

This script automates the setup and management of a Cloud Spanner instance for an e-commerce application. It performs the following tasks:

## Prerequisites
- Ensure you have the Google Cloud SDK installed and configured.
- Replace the `REGION` variable with your desired region.

## Tasks Performed by the Script

1. **Enable Cloud Spanner API**: Enables the Cloud Spanner API for your project.
2. **Create a Cloud Spanner Instance**: Creates a Cloud Spanner instance named `ecommerce-instance`.
3. **Create a Database**: Creates a database named `ecommerce-db` within the instance.
4. **Create a Schema**: Defines a schema for the `Products` table.
5. **Insert Data**: Inserts sample data into the `Products` table.
6. **Modify Data**: Updates the stock for a specific product.
7. **Delete Data**: Deletes a product from the `Products` table.
8. **Run a Query**: Fetches and displays all rows from the `Products` table.

## Usage

1. Save the script to a file, e.g., `spanner.sh`.
2. Make the script executable:
   ```bash
   chmod +x spanner.sh
   ```
3. Run the script:
   ```bash
   ./spanner.sh
   ```

## Notes
- Modify the `INSTANCE_NAME`, `DATABASE_NAME`, and `REGION` variables as needed.
- Ensure you have the necessary permissions to create and manage Cloud Spanner resources.

## Output
The script will output the progress of each task and confirm when all tasks are completed.
