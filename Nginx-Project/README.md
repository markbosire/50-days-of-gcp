# Documentation for Setting Up Terraform with GCP

This documentation outlines the steps to set up Terraform with Google Cloud Platform (GCP), including enabling necessary APIs, creating a service account, and applying Terraform configurations.

## Prerequisites
1. **Google Cloud SDK** installed on your local machine.
2. **Terraform CLI** installed.
3. A GCP project. Replace `your-project-id` with your project ID where applicable.

---

## Step 1: Set the GCP Project
Set the GCP project to use for subsequent commands:
```bash
PROJECT_ID=your-project-id
gcloud config set project $PROJECT_ID
```

---

## Step 2: Enable Required APIs
Enable the following APIs necessary for Terraform:
```bash
gcloud services enable \
    compute.googleapis.com \
    storage.googleapis.com \
    iam.googleapis.com
```

---

## Step 3: Create a Service Account
Create a service account for Terraform:
```bash
gcloud iam service-accounts create my-service-account \
  --description="Service account for Terraform" \
  --display-name="Terraform Service Account"
```

---

## Step 4: Assign Roles to the Service Account
Grant the `roles/compute.admin` role to the service account:
```bash
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:my-service-account@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/compute.admin"
```

---

## Step 5: Create and Download a Key for the Service Account
Generate a JSON key for the service account and save it to your local machine:
```bash
gcloud iam service-accounts keys create "terraform-service-account-key.json" \
  --iam-account="my-service-account@$PROJECT_ID.iam.gserviceaccount.com"
```

---

## Step 6: Set the Google Application Credentials Environment Variable
Export the service account key file path:
```bash
export GOOGLE_APPLICATION_CREDENTIALS="terraform-service-account-key.json"
```

---

## Step 7: Create a Terraform Variables File
Create a `terraform.tfvars` file and add your project ID to it:
```bash
echo "project_id = \"$PROJECT_ID\"" > terraform.tfvars
```

---

## Step 8: Plan and Apply Terraform Configuration
Run the following Terraform commands to initialize, plan, and apply your configuration:

### Initialize Terraform:
```bash
terraform init
```

### Plan the Terraform Execution:
```bash
terraform plan
```

### Apply the Terraform Configuration:
```bash
terraform apply
```

---

## Notes
- Replace `your-project-id` with your actual project ID wherever applicable.
- Ensure your service account JSON key file is kept secure and is not exposed publicly.
- Verify the state of your Terraform resources using `terraform show` or `terraform state list` after applying.

