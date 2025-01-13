#!/bin/bash

# Variables
INSTANCE_NAME="ecommerce-instance"
DATABASE_NAME="ecommerce-db"
REGION="us-central1"  # Change this to your desired region

# Step 0: Enable Cloud Spanner API
echo "Enabling Cloud Spanner API..."
gcloud services enable spanner.googleapis.com

# Task 1: Create a Cloud Spanner Instance
echo "Creating Cloud Spanner instance for e-commerce..."
gcloud spanner instances create $INSTANCE_NAME \
    --config=regional-$REGION \
    --description="E-commerce Instance" \
    --nodes=1

# Task 2: Create a Database
echo "Creating database '$DATABASE_NAME' in instance '$INSTANCE_NAME'..."
gcloud spanner databases create $DATABASE_NAME \
    --instance=$INSTANCE_NAME

# Task 3: Create a Schema
echo "Creating schema for table 'Products'..."
gcloud spanner databases ddl update $DATABASE_NAME \
    --instance=$INSTANCE_NAME \
    --ddl="CREATE TABLE Products (
        ProductId   INT64 NOT NULL,
        ProductName STRING(1024),
        Category    STRING(1024),
        Price       FLOAT64,
        Stock       INT64,
        CreatedAt   TIMESTAMP OPTIONS (allow_commit_timestamp=true),
    ) PRIMARY KEY(ProductId);"

# Task 4: Insert Data
echo "Inserting data into 'Products' table..."
gcloud spanner databases execute-sql $DATABASE_NAME \
    --instance=$INSTANCE_NAME \
    --sql="INSERT INTO Products (ProductId, ProductName, Category, Price, Stock, CreatedAt)
           VALUES (1, 'Laptop', 'Electronics', 999.99, 50, PENDING_COMMIT_TIMESTAMP()),
                  (2, 'Smartphone', 'Electronics', 499.99, 100, PENDING_COMMIT_TIMESTAMP()),
                  (3, 'Headphones', 'Electronics', 149.99, 200, PENDING_COMMIT_TIMESTAMP());"

# Task 5: Modify Data
echo "Updating stock for ProductId 1..."
gcloud spanner databases execute-sql $DATABASE_NAME \
    --instance=$INSTANCE_NAME \
    --sql="UPDATE Products
           SET Stock = 45
           WHERE ProductId = 1;"

# Task 6: Delete Data
echo "Deleting data for ProductId 3..."
gcloud spanner databases execute-sql $DATABASE_NAME \
    --instance=$INSTANCE_NAME \
    --sql="DELETE FROM Products WHERE ProductId = 3;"

# Task 7: Run a Query
echo "Running query to fetch all rows from 'Products' table..."
gcloud spanner databases execute-sql $DATABASE_NAME \
    --instance=$INSTANCE_NAME \
    --sql="SELECT * FROM Products;"

echo "All e-commerce tasks completed!"
