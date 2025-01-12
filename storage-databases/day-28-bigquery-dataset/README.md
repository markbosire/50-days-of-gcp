# World Cities Dataset Loader Script

This script automates the process of loading a dataset of world cities into Google BigQuery and performing some basic queries on the data. The dataset contains information about cities, including their names, countries, subcountries, and geoname IDs.

## Prerequisites

- **Google Cloud SDK**: Ensure that the Google Cloud SDK is installed and configured with the necessary permissions to access BigQuery.
- **BigQuery**: You should have a BigQuery project set up where the dataset will be created.

## Usage

1. **Clone the repository** (if applicable) or copy the script to your local machine.
2. **Run the script**:

   ```bash
   bash load_world_cities.sh
   ```

## What the Script Does

1. **Creates a new dataset** named `world_cities` in BigQuery.
2. **Downloads the dataset** from the provided URL (`https://raw.githubusercontent.com/datasets/world-cities/master/data/world-cities.csv`) and saves it as `world-cities.csv`.
3. **Uploads the CSV file** to BigQuery using the specified schema (`name:string,country:string,subcountry:string,geonameid:integer`).
4. **Confirms the creation** of the dataset and table by listing them.
5. **Runs two sample queries**:
   - Lists 5 cities in Japan ordered by `geonameid`.
   - Counts the number of cities in each country and lists the top 5 countries with the most cities.

## Variables

- `DATASET_NAME`: The name of the dataset to be created in BigQuery (`world_cities`).
- `TABLE_NAME`: The name of the table within the dataset (`cities`).
- `DATASET_URL`: The URL from which the dataset is downloaded.
- `CSV_FILE`: The local filename for the downloaded CSV (`world-cities.csv`).
- `SCHEMA`: The schema definition for the BigQuery table.

