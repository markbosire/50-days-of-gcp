# **Setup DNS and Host a Portfolio on Google Cloud**

This script automates the deployment of a portfolio website on Google Cloud. It sets up a custom VPC, configures DNS, creates a VM with Apache, and sets up a global load balancer with HTTPS support.

## **Prerequisites**
- Google Cloud SDK installed and configured.
- A domain name (e.g., `example.com`).
- Billing enabled on your Google Cloud project.

## **Setup Instructions**
1. Clone the repository or download the script.
2. Replace `example.com` in the script with your actual domain name.
3. Make the script executable:
   ```bash
   chmod +x setup-dns.sh
   ```
4. Run the script:
   ```bash
   ./setup-dns.sh
   ```

## **What the Script Does**
1. **Networking**:
   - Creates a custom VPC and subnet.
   - Adds firewall rules for HTTP, HTTPS, and SSH.

2. **DNS and SSL**:
   - Reserves a static IP for the load balancer.
   - Sets up a DNS zone and A record for your domain.
   - Creates a Google-managed SSL certificate.

3. **VM Setup**:
   - Creates a VM with Apache installed.
   - Configures the VM using a startup script

4. **Load Balancing**:
   - Creates an instance group and adds the VM.
   - Sets up a health check, backend service, URL map, and HTTPS proxy.
   - Configures a global forwarding rule for HTTPS traffic.

5. **Output**:
   - Prints the load balancer IP and DNS nameservers to configure at your domain registrar.

## **Cleanup**
```
gcloud compute forwarding-rules delete portfolio-https-forwarding-rule --global --quiet
gcloud compute target-https-proxies delete portfolio-https-proxy --quiet
gcloud compute url-maps delete portfolio-url-map --quiet
gcloud compute backend-services delete portfolio-backend-service --global --quiet
gcloud compute health-checks delete portfolio-health-check --quiet
gcloud compute instance-groups unmanaged delete portfolio-instance-group --zone=us-central1-a --quiet
gcloud compute instances delete portfolio-vm --zone=us-central1-a --quiet
gcloud compute ssl-certificates delete portfolio-ssl-cert --quiet
gcloud dns record-sets delete markbosire.click. --zone=portfolio-dns-zone --type=A --quiet
gcloud dns managed-zones delete portfolio-dns-zone --quiet
gcloud compute addresses delete portfolio-lb-ip --global --quiet
gcloud compute firewall-rules delete portfolio-allow-http --quiet
gcloud compute firewall-rules delete portfolio-allow-https --quiet
gcloud compute firewall-rules delete portfolio-allow-ssh --quiet
gcloud compute networks subnets delete portfolio-subnet --region=us-central1 --quiet
gcloud compute networks delete portfolio-vpc --quiet
```
