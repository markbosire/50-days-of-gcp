# Weather Analytics System Setup

This script automates the setup of a Google Cloud Bigtable instance and a Compute Engine VM with a startup script to install necessary tools for inserting dummy weather data.

## Steps

1. **Create Bigtable Instance**  
   The script dynamically retrieves the active Google Cloud project ID and creates a Bigtable instance with a cluster.

2. **Create Compute Engine VM**  
   A VM is created with a startup script that installs Google Cloud SDK and Cloud Bigtable Command-Line Tool (`cbt`).

3. **Add SSH Firewall Rule**  
   A firewall rule is added to allow SSH access to the VM.

4. **Insert Dummy Data**  
   The script connects to the VM via SSH, configures Bigtable, creates a table, inserts dummy weather data, and queries the data.

## Usage

1. Make sure `gcloud` is installed and configured.
2. Save the script as `setup.sh`.
3. Run the script:

   ```bash
   bash setup.sh
   ```

## Cleanup

```bash
gcloud bigtable instances delete weather-instance --quiet
gcloud compute instances delete bigtable-vm --zone=us-central1-a --quiet 
gcloud compute firewall-rules delete allow-ssh --quiet
```
