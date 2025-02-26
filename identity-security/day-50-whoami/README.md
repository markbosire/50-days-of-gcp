### **README: Verifying Google Cloud Project and User Configuration**  

This guide provides steps to verify your **Google Cloud user account, active project, and configuration details** using the `gcloud` CLI.  

## **Steps**  

### **1. Verify the Active User Account**  
Check which user account is authenticated:  
```sh
gcloud auth list --filter=status:ACTIVE --format="value(account)"
```  
If no user is listed, authenticate with:  
```sh
gcloud auth login
```  

### **2. Check the Active Project**  
View the currently set project:  
```sh
gcloud config get-value project
```  
If the project is incorrect or not set, update it:  
```sh
gcloud config set project PROJECT_ID
```  

### **3. Retrieve Full Configuration Details**  
Check all active configurations:  
```sh
gcloud config list --format json
```  
If the region or zone is missing, set them:  
```sh
gcloud config set compute/region REGION
gcloud config set compute/zone ZONE
```  

### **4. Get Project Metadata**  
Retrieve project details such as billing and IAM policies:  
```sh
gcloud projects describe PROJECT_ID
```  

### **Conclusion**  
Following these steps ensures you are working within the correct **Google Cloud environment**. 🚀
