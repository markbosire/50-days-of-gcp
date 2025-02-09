## **Cloud Audit Logs - IAM Activity Script**  

### **Overview**  
This script demonstrates how to enable **Cloud Audit Logs** for IAM, perform an IAM role assignment, retrieve audit logs, and clean up by revoking the assigned role. It helps in monitoring IAM policy changes and tracking who made modifications in a Google Cloud project.  

### **Prerequisites**  
- Google Cloud SDK (`gcloud`) installed and authenticated  
- Project configured using `gcloud config set project [PROJECT_ID]`  
- `jq` installed for parsing JSON output  

### **Usage**  
1. **Enable Cloud Audit Logs** – Ensures IAM activities are logged.  
2. **Assign an IAM Role** – Grants the `iap.tunnelResourceAccessor` role to the current user.  
3. **Wait for Log Generation** – Allows logs to be recorded.  
4. **Retrieve IAM Audit Logs** – Queries Cloud Audit Logs to show IAM-related activities.  
5. **Revoke the IAM Role** – Removes the role assigned earlier.  

### **Execution**  
Run the script:  
```bash
chmod +x audit_logs.sh
./audit_logs.sh
```  

### **Expected Output**  
- A log entry displaying IAM modifications, including the timestamp, method used, and the user who performed the action.  
- Confirmation that the IAM role has been granted and later removed.  

This script is useful for investigating IAM changes and ensuring compliance with security policies.
