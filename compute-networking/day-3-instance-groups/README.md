# Nginx Container Deployment with Autoscaling on GCP

This repository contains a bash script to deploy an Nginx demo application using Google Cloud Platform's Managed Instance Groups with autoscaling and load balancing capabilities.

## Components Created

1. Firewall Rules
   - Rule name: allow-http-nginx
   - Allows incoming traffic on port 80
   - Applied to instances with 'http-server' tag

2. Instance Template
   - Name: nginx-template
   - Container image: nginxdemos/hello
   - Network tags: http-server

3. Managed Instance Group
   - Name: nginx-mig
   - Based on nginx-template
   - Autoscaling enabled

4. Load Balancer Components
   - Health check (port 80)
   - Backend service
   - URL map
   - HTTP proxy
   - Global forwarding rule

## Usage

1. Make the script executable:
```bash
chmod +x deploy-nginx.sh
```

2. Run the script:
```bash
./deploy-nginx.sh
```

3. Monitor deployment:
   - Script will display the Load Balancer IP address
   - Wait approximately 30 seconds for the load balancer to be ready
   - Use the provided monitoring command to check instance status

## Monitoring

To monitor the instances in your managed instance group:
```bash
gcloud compute instance-groups managed list-instances nginx-mig --zone=us-central1-a
```

## Deployment Summary

The script will output a summary including:
- Instance template name
- Instance group details
- Autoscaling configuration
- Region and zone information
- Firewall rule details

## Error Handling

The script includes:
- Automatic exit on any error (`set -e`)
- Error message trap for better debugging
- Clear status messages during deployment

## Clean-up Procedure

To remove all created resources, execute these commands in order:

```bash
# Delete forwarding rule
gcloud compute forwarding-rules delete nginx-forwarding-rule --global

# Delete proxy
gcloud compute target-http-proxies delete nginx-proxy

# Delete URL map
gcloud compute url-maps delete nginx-map

# Delete backend service
gcloud compute backend-services delete nginx-backend --global

# Delete health check
gcloud compute health-checks delete nginx-health-check

# Delete instance group
gcloud compute instance-groups managed delete nginx-mig --zone=us-central1-a

# Delete instance template
gcloud compute instance-templates delete nginx-template

# Delete firewall rule
gcloud compute firewall-rules delete allow-http-nginx
```

Note: Add `-q` flag to any command to skip confirmation prompts

## Support

For issues or questions, please:
1. Check the Google Cloud documentation
2. Verify your Google Cloud SDK is up to date
3. Ensure you have the necessary permissions

## License

This script is provided as-is under the MIT license.
