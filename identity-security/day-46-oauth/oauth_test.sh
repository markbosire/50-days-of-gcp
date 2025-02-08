#!/bin/bash

# Get an OAuth 2.0 access token
TOKEN=$(gcloud auth application-default print-access-token)

# Get the current project ID
PROJECT_ID=$(gcloud config get-value project)

# Fetch IAM policy details for the project
curl -s -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d '{}' \
    "https://cloudresourcemanager.googleapis.com/v1/projects/${PROJECT_ID}:getIamPolicy" | jq .

