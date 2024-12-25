# Secure SSH Access Setup on GCP

This project automates the process of setting up a secure SSH access policy for a Google Cloud Platform (GCP) virtual machine (VM). The setup ensures that only a specified corporate IP address can access the VM via SSH, enhancing security and compliance with organizational policies.

## Features

- Deploy a lightweight Debian-based VM instance with SSH access.
- Automatically identify the public IP of your corporate network.
- Configure GCP firewall rules to restrict SSH access to a single IP address.
- Disable default SSH access for added security.
- Test and verify SSH access policies.
- Generate a documentation file summarizing the setup.

## Outputs

1. **VM Instance**: A Debian-based VM with restricted SSH access.
2. **Firewall Rule**: `allow-corporate-ssh` enabling SSH only for the specified corporate IP.
3. **Policy Document**: `ssh_access_policy.txt` detailing the access policy.

## Cleanup
To remove the resources created during this setup:

```bash
gcloud compute instances delete secure-ssh-vm --zone=us-central1-a --quiet
gcloud compute firewall-rules delete allow-corporate-ssh --quiet
```
