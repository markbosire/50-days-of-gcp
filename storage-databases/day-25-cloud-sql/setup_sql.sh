#!/bin/bash

# Variables
INSTANCE_NAME="loyalty-db"
DATABASE_NAME="loyalty_program"
TABLE_NAME="customers"
DB_USER="root"
DB_PASSWORD="yourpassword"  # Replace with a secure password
REGION="us-central1"
TIER="db-f1-micro"

# Step 0: Enable necessary APIs
echo "Enabling necessary APIs..."
gcloud services enable sqladmin.googleapis.com
gcloud services enable sql-component.googleapis.com

# Step 1: Create a Cloud SQL instance
echo "Creating Cloud SQL instance..."
echo "Waiting for a few minutes to ensure the database is stable..."
gcloud sql instances create $INSTANCE_NAME \
    --database-version=MYSQL_8_0 \
    --tier=$TIER \
    --region=$REGION \
    --root-password=$DB_PASSWORD


# Step 2: Create a database and table
echo "Creating database and table..."
gcloud sql connect $INSTANCE_NAME --user=$DB_USER --quiet <<EOF
CREATE DATABASE $DATABASE_NAME;
USE $DATABASE_NAME;
CREATE TABLE $TABLE_NAME (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(15),
    total_points INT DEFAULT 0
);
EOF

# Step 3: Wait for 1 minute
echo "Waiting for a minute to ensure the database is stable..."
sleep 60

# Step 4: Insert test data
echo "Inserting test data..."
gcloud sql connect $INSTANCE_NAME --user=$DB_USER --quiet <<EOF
USE $DATABASE_NAME;
INSERT INTO $TABLE_NAME (name, email, phone, total_points) VALUES
('John Doe', 'john.doe@example.com', '123-456-7890', 100),
('Jane Smith', 'jane.smith@example.com', '987-654-3210', 200);
EOF

# Step 5: Retrieve and verify data
echo "Retrieving data for verification..."
gcloud sql connect $INSTANCE_NAME --user=$DB_USER --quiet <<EOF
USE $DATABASE_NAME;
SELECT * FROM $TABLE_NAME;
EOF

# Step 6: Clean up (optional)
echo "Script completed. To delete the instance, run:"
echo "gcloud sql instances delete $INSTANCE_NAME"
