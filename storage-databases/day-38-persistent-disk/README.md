# Google Cloud VM and Disk Management Scripts

This repository contains two scripts to automate the creation and cleanup of a Google Cloud VM instance with an attached persistent disk.

## Scripts

### 1. `pd.sh`
This script automates the following tasks:
- Creates a new Compute Engine VM instance.
- Creates a new persistent disk.
- Attaches the disk to the VM.
- Displays the final status of the VM and attached disk.

#### Usage:
```bash
bash pd.sh
```

#### Variables:
- `ZONE`: The zone where the VM and disk will be created (default: `us-central1-a`).
- `INSTANCE_NAME`: The name of the VM instance (default: `my-vm-instance`).
- `DISK_NAME`: The name of the persistent disk (default: `my-persistent-disk`).

---

### 2. `cleanup.sh`
This script automates the cleanup process:
- Detaches the persistent disk from the VM.
- Deletes the VM instance.
- Deletes the persistent disk.

#### Usage:
```bash
bash cleanup.sh
```

#### Notes:
- Ensure the VM and disk names match those used in `pd.sh`.
- The `--quiet` flag suppresses confirmation prompts.

---

## Prerequisites
- Google Cloud SDK (`gcloud`) installed and configured.
- Appropriate permissions to create and manage Compute Engine resources.

