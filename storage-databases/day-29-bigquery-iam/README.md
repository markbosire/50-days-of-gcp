
# BigQuery Setup and Service Account Testing

This script automates the setup of a BigQuery dataset, creates sample data, and configures and tests service accounts with specific permissions.

## Steps Performed by the Script

1. **Retrieve Project ID and User Email**  
   - Fetches the default project ID and current user email from the gcloud configuration.

2. **Create BigQuery Dataset and Sample Table**  
   - Creates a dataset named `demo_dataset`.  
   - Generates a sample table with 10 rows of test data, including a unique ID, product name, price, and timestamp.

3. **Create Service Accounts**  
   - Creates two service accounts:  
     - `data-engineering-sa` for data engineering tasks.  
     - `data-science-sa` for data science tasks.  

4. **Grant Token Creator Role to User**  
   - Grants the `Service Account Token Creator` role to the current user for both service accounts to enable impersonation.

5. **Assign BigQuery Roles to Service Accounts**  
   - Grants the `BigQuery Data Editor` role to `data-engineering-sa` for read/write access.  
   - Grants the `BigQuery Data Viewer` role to `data-science-sa` for read-only access.  

6. **Test Service Account Permissions**  
   - Tests the permissions of both service accounts:  
     - Verifies that `data-engineering-sa` can read and write data.  
     - Verifies that `data-science-sa` can read data but cannot write data.  

7. **Reset Impersonation**  
   - Reverts to the original user account after testing.

## Expected Results
- **Data Engineering Service Account**: Should successfully read and write data.  
- **Data Science Service Account**: Should successfully read data but fail to write data.  

## Usage
Run the script in a terminal with gcloud and bq CLI configured:
```bash
bash script_name.sh
```

## Notes
- Ensure you have the necessary permissions to create service accounts and assign roles in your Google Cloud project.  
- The script includes a 60-second delay to allow IAM permissions to propagate.  
