# Custom Storage Object Viewer Role Creation Script

This script (`custom_roles.sh`) creates a custom IAM role in Google Cloud with the same permissions as the `Storage Object Viewer` role, but with the added permission to create storage objects.

## Steps

1. The script retrieves the current project ID.
2. Copies the existing `roles/storage.objectViewer` role.
3. Adds the `storage.objects.create` permission to the copied role.
4. Outputs the final policy for the new role.

## Prerequisites

- Google Cloud SDK (`gcloud`) must be installed and authenticated.
- The project must be set up in Google Cloud.

## Usage

1. Download or clone the `custom_roles.sh` script.
2. Make the script executable:
   ```bash
   chmod +x custom_roles.sh
   ```
3. Run the script:
   ```bash
   ./custom_roles.sh
   ```

The script will create a custom role with the `storage.objects.create` permission.

## Cleanup

To delete the custom role after use, run the following command:

```bash
gcloud iam roles delete "$NEW_ROLE_ID" --project "$PROJECT_ID" --quiet
```

This will remove the custom role from your project.

