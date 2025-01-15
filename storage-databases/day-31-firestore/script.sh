#!/bin/bash

# Automatically fetch the current Google Cloud project ID
PROJECT_ID=$(gcloud config get-value project)

# Step 0: Enable necessary APIs
echo "Enabling necessary APIs..."
gcloud services enable firestore.googleapis.com \
    compute.googleapis.com \
    cloudresourcemanager.googleapis.com \
    --project=$PROJECT_ID

# Rest of your script...
REGION="us-central1"                     # Google Cloud region
DATABASE_NAME="firestore-database"              # Firestore database name
INSTANCE_NAME="firestore-data-generator" # VM instance name
ZONE="us-central1-a"                     # Google Cloud zone
FIREWALL_RULE_NAME="allow-ssh"           # Firewall rule name for SSH
PYTHON_SCRIPT_ADD_DATA="add_data_to_firestore.py"    # Python script to add data
PYTHON_SCRIPT_VIEW_DATA="view_data_from_firestore.py" # Python script to view data

# Step 1: Create a Firestore Database
echo "Creating Firestore database in project: $PROJECT_ID..."
gcloud firestore databases create --project=$PROJECT_ID --location=$REGION --database=$DATABASE_NAME

# Step 2: Create a VM instance
echo "Creating VM instance: $INSTANCE_NAME..."
gcloud compute instances create $INSTANCE_NAME \
    --project=$PROJECT_ID \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --tags=firestore-ssh \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --metadata=startup-script="#!/bin/bash
        apt update
        apt install -y python3-pip
        "
        
        
echo "VM instance provisioning ..."        
sleep 60

# Step 3: Create a firewall rule for SSH
echo "Creating firewall rule: $FIREWALL_RULE_NAME..."
gcloud compute firewall-rules create $FIREWALL_RULE_NAME \
    --project=$PROJECT_ID \
    --allow=tcp:22 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=firestore-ssh

echo "Adding fake data to Firestore..."
gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --command="
    pip install faker google-cloud-firestore --quiet
    cat > $PYTHON_SCRIPT_ADD_DATA << 'EOF'
from faker import Faker
from google.cloud import firestore

fake = Faker()

# Initialize Firestore client with the specified database
db = firestore.Client(database='$DATABASE_NAME')

# Add fake data to Firestore with collections and subcollections
for _ in range(10):  # Add 10 fake entries
    # Create a document in the 'users' collection
    user_ref = db.collection('users').document()
    user_data = {
        'name': fake.name(),
        'email': fake.email(),
        'address': fake.address(),
        'phone_number': fake.phone_number()
    }
    user_ref.set(user_data)
    print(f'Added user document with ID: {user_ref.id}')

    # Create a subcollection 'orders' under the user document
    for _ in range(3):  # Add 3 fake orders per user
        order_ref = user_ref.collection('orders').document()
        order_data = {
            'order_id': fake.uuid4(),
            'product': fake.word(),
            'quantity': fake.random_int(min=1, max=10),
            'price': fake.random_number(digits=2),
            'date': fake.date_this_year().isoformat()
        }
        order_ref.set(order_data)
        print(f'Added order document with ID: {order_ref.id} under user {user_ref.id}')
EOF

    python3 $PYTHON_SCRIPT_ADD_DATA
"

# Step 5: SSH into the instance and run the Python script to view data from Firestore
echo "Viewing data from Firestore..."
gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --command="
    cat > $PYTHON_SCRIPT_VIEW_DATA << 'EOF'
from google.cloud import firestore

# Initialize Firestore client with the specified database
db = firestore.Client(database='$DATABASE_NAME')

def print_document(doc, indent=0):
    print(' ' * indent + f'Document ID: {doc.id}')
    print(' ' * indent + f'Data: {doc.to_dict()}\n')

def print_collection(collection_ref, indent=0):
    docs = collection_ref.stream()
    for doc in docs:
        print_document(doc, indent)
        # Recursively print subcollections
        for subcollection in doc.reference.collections():
            print(' ' * indent + f'Subcollection: {subcollection.id}')
            print_collection(subcollection, indent + 4)

# Retrieve and print all documents from the 'users' collection and their subcollections
print('Fetching data from Firestore...')
users_ref = db.collection('users')
print_collection(users_ref)
EOF

    python3 $PYTHON_SCRIPT_VIEW_DATA
"

echo "Setup and data operations completed successfully!"
