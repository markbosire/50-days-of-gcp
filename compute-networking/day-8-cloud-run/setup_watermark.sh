#!/bin/bash

# Set variables
echo "Setting variables..."
PROJECT_ID=$(gcloud config get-value project)
REGION="us-central1"
BUCKET_NAME="${PROJECT_ID}-watermark-bucket"
FUNCTION_SA_NAME="cloud-function-sa"
FUNCTION_SA_EMAIL="${FUNCTION_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# Enable required APIs
echo "Enabling required Google Cloud APIs..."
gcloud services enable \
    cloudfunctions.googleapis.com \
    cloudbuild.googleapis.com \
    artifactregistry.googleapis.com \
    storage.googleapis.com \
    run.googleapis.com \
    eventarc.googleapis.com \
    pubsub.googleapis.com \
    iam.googleapis.com

# Create the Cloud Function service account
echo "Creating the Cloud Function service account..."
gcloud iam service-accounts create $FUNCTION_SA_NAME \
    --display-name="Cloud Function Service Account"

# Grant IAM roles to the Cloud Function service account
echo "Granting IAM roles to the Cloud Function service account..."
for role in \
    "roles/eventarc.eventReceiver" \
    "roles/pubsub.publisher" \
    "roles/cloudfunctions.invoker" \
    "roles/cloudfunctions.developer" \
    "roles/run.invoker"
do
    echo "Assigning role $role..."
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:${FUNCTION_SA_EMAIL}" \
        --role="$role"
done

# Create the Cloud Storage bucket
echo "Creating the Cloud Storage bucket..."
gcloud storage buckets create gs://${BUCKET_NAME} --location=${REGION}

# Get the Cloud Storage service account
echo "Retrieving the Cloud Storage service account..."
GCS_SERVICE_ACCOUNT="service-$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')@gs-project-accounts.iam.gserviceaccount.com"

# Grant the Pub/Sub Publisher role to the Cloud Storage service account
echo "Granting Pub/Sub Publisher role to the Cloud Storage service account..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${GCS_SERVICE_ACCOUNT}" \
    --role="roles/pubsub.publisher"

# Grant roles to the Cloud Function service account for the bucket
echo "Granting bucket roles to the Cloud Function service account..."
gcloud storage buckets add-iam-policy-binding gs://${BUCKET_NAME} \
    --member="serviceAccount:${FUNCTION_SA_EMAIL}" \
    --role="roles/storage.objectViewer"

gcloud storage buckets add-iam-policy-binding gs://${BUCKET_NAME} \
    --member="serviceAccount:${FUNCTION_SA_EMAIL}" \
    --role="roles/storage.objectUser"

# Set up the function directory
echo "Setting up the Cloud Function directory structure..."
mkdir -p watermark-function
cd watermark-function

# Download the watermark image
echo "Downloading the watermark image..."
curl -o watermark.png https://raw.githubusercontent.com/markbosire/100-days-of-gcp/refs/heads/main/compute-networking/day-8-cloud-run/logo.png

# Create the main.py file
echo "Creating the main.py file..."
cat > main.py << 'EOL'
import os
from google.cloud import storage
from PIL import Image

# Initialize Google Cloud Storage client
storage_client = storage.Client()

# Path to the watermark file
WATERMARK_FILE = "watermark.png"

def add_watermark(input_path, output_path):
    """Adds a translucent, centered watermark to an image."""
    # Check if the watermark file exists
    if not os.path.exists(WATERMARK_FILE):
        print(f"Error: Watermark file '{WATERMARK_FILE}' not found.")
        return

    with Image.open(input_path) as img:
        watermark = Image.open(WATERMARK_FILE)

        # Ensure watermark is in RGBA mode
        watermark = watermark.convert("RGBA")
        
        # Resize watermark if it's too large (optional)
        watermark = watermark.resize((img.width // 4, img.height // 4))  # Adjust size as needed
        
        # Create a new watermark with adjusted transparency
        translucent_watermark = Image.new("RGBA", watermark.size)
        watermark_pixels = watermark.load()
        translucent_pixels = translucent_watermark.load()

        for x in range(watermark.width):
            for y in range(watermark.height):
                r, g, b, a = watermark_pixels[x, y]
                # Preserve fully transparent pixels
                if a == 0:
                    translucent_pixels[x, y] = (0, 0, 0, 0)
                else:
                    # Adjust alpha for translucency
                    translucent_pixels[x, y] = (r, g, b, int(a * 0.5))  # 50% transparency

        # Calculate position to center watermark
        watermark_width, watermark_height = watermark.size
        position = ((img.width - watermark_width) // 2, (img.height - watermark_height) // 2)
        
        # Paste the translucent watermark
        img.paste(translucent_watermark, position, translucent_watermark)
        img.save(output_path)

def watermark_image(event, context):
    """Background Cloud Function triggered by Cloud Storage."""
    bucket_name = event['bucket']
    file_name = event['name']

    if not file_name.lower().endswith(('.png', '.jpg', '.jpeg')):
        print(f"Skipping non-image file: {file_name}")
        return

    # Paths for temporary storage
    temp_local_file = f"/tmp/{file_name}"
    temp_local_output = f"/tmp/watermarked-{file_name}"

    # Download the image from GCS
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(file_name)
    blob.download_to_filename(temp_local_file)
    print(f"Downloaded {file_name} to {temp_local_file}")

    # Add the watermark
    add_watermark(temp_local_file, temp_local_output)
    print(f"Watermark added to {temp_local_output}")

    # Upload the watermarked image to GCS
    output_blob = bucket.blob(f"watermarked/{file_name}")
    output_blob.upload_from_filename(temp_local_output)
    print(f"Uploaded watermarked image to watermarked/{file_name}")
EOL

# Create the requirements.txt file
echo "Creating the requirements.txt file..."
cat > requirements.txt << 'EOL'
google-cloud-storage
Pillow
EOL

# Deploy the Cloud Function
echo "Deploying the Cloud Function..."
gcloud functions deploy watermark-image \
    --runtime python310 \
    --trigger-resource ${BUCKET_NAME} \
    --trigger-event google.storage.object.finalize \
    --entry-point watermark_image \
    --region ${REGION} \
    --source . \
    --service-account ${FUNCTION_SA_EMAIL} \
    --set-env-vars BUCKET_NAME=${BUCKET_NAME}

# Test the setup
echo "Testing the setup..."
curl -L -o random_image.jpg https://picsum.photos/800/600
gcloud storage cp random_image.jpg gs://${BUCKET_NAME}/
echo "waiting for the file to be processed"
sleep 20
echo "Listing watermarked images in the bucket..."
gcloud storage ls gs://${BUCKET_NAME}/watermarked/
echo "Downloading the watermarked image..."
gcloud storage cp gs://${BUCKET_NAME}/watermarked/random_image.jpg random_image_watermark.jpg

echo "Script execution completed."

