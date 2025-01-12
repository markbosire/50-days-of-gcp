#!/bin/bash

# Variables
DATASET_NAME="world_cities"
TABLE_NAME="cities"
DATASET_URL="https://raw.githubusercontent.com/datasets/world-cities/master/data/world-cities.csv"
CSV_FILE="world-cities.csv"
SCHEMA="name:string,country:string,subcountry:string,geonameid:integer"

# Step 1: Create a new dataset
echo "Creating dataset $DATASET_NAME..."
bq mk $DATASET_NAME

# Step 2: Download the dataset using curl
echo "Downloading dataset from $DATASET_URL..."
curl -o $CSV_FILE $DATASET_URL

# Step 3: Upload the CSV file to BigQuery
echo "Uploading $CSV_FILE to BigQuery..."
bq load --source_format=CSV --skip_leading_rows=1 $DATASET_NAME.$TABLE_NAME $CSV_FILE $SCHEMA

# Step 4: Confirm the dataset and table creation
echo "Listing datasets..."
bq ls

echo "Listing tables in dataset $DATASET_NAME..."
bq ls $DATASET_NAME

# Step 5: Query the data
echo "Querying 5 cities in Japan ordered by geonameid..."
bq query --use_legacy_sql=false \
"SELECT
  name,
  subcountry,
  geonameid
FROM
  $DATASET_NAME.$TABLE_NAME
WHERE
  country = 'Japan'
ORDER BY
  geonameid
LIMIT 5"

echo "Querying the number of cities in each country..."
bq query --use_legacy_sql=false \
"SELECT
  country,
  COUNT(*) AS total_cities
FROM
  $DATASET_NAME.$TABLE_NAME
GROUP BY
  country
ORDER BY
  total_cities DESC
LIMIT 5"

echo "Script completed successfully."
