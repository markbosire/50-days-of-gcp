# Google Cloud Filestore and Compute Engine Setup and Cleanup

This repository contains two scripts to automate the setup and cleanup of a Google Cloud environment that includes a **Cloud Filestore** instance and a **Compute Engine** instance. The setup script (`filestore.sh`) creates a custom VPC network, a subnet, a firewall rule, a Compute Engine instance, and a Cloud Filestore instance. The cleanup script (`cleanup.sh`) removes all the resources created by the setup script.

---

## **Scripts Overview**

### **1. `filestore.sh`**
This script performs the following tasks:
1. Enables necessary Google Cloud APIs (**Cloud Filestore** and **Compute Engine**).
2. Creates a custom VPC network and subnet.
3. Creates a firewall rule to allow SSH access from anywhere.
4. Launches a Compute Engine instance with the `nfs-common` package installed.
5. Creates a Cloud Filestore instance with a 1TB file share.
6. Mounts the Filestore file share to the Compute Engine instance.
7. Creates and verifies a test file on the mounted file share.

---

### **2. `cleanup.sh`**
This script performs the following cleanup tasks:
1. Unmounts the Filestore file share from the Compute Engine instance.
2. Deletes the Compute Engine instance.
3. Deletes the Cloud Filestore instance.
4. Deletes the firewall rule.
5. Deletes the subnet.
6. Deletes the custom VPC network.

---

## **Prerequisites**
- A Google Cloud project with billing enabled.
- The **gcloud CLI** installed and configured on your local machine.
- Sufficient permissions to create and delete resources in the project.

---

## **Usage**

### **1. Setup Environment**
Run the `filestore.sh` script to set up the environment:
```bash
bash filestore.sh
```

### **2. Cleanup Environment**
Run the `cleanup.sh` script to delete all resources created by the setup script:
```bash
bash cleanup.sh
```

---

