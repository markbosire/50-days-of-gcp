# CPU Load Testing with Autoscaling on GCP

A simple setup script to demonstrate GCP's autoscaling capabilities using stress-ng for CPU load simulation.

## Features
- Creates an instance template with stress-ng for CPU load testing
- Sets up a managed instance group with autoscaling
- Configures automatic scaling based on CPU utilization (60% threshold)
- Includes monitoring capabilities

## Usage
```bash
# Make the script executable
chmod +x setup_autoscaling.sh

# Run the setup
./setup_autoscaling.sh
```


## Monitoring
Monitor instance scaling:
```bash
watch -n 5 gcloud compute instance-groups managed list-instances cpu-load-group-worst --zone=us-central1-a
```

## Cleanup
To remove all created resources:
```bash
gcloud compute instance-groups managed delete cpu-load-group-worst --zone=us-central1-a --quiet
gcloud compute instance-templates delete cpu-load-template-worst --quiet
gcloud compute firewall-rules delete allow-ssh --quiet
```
