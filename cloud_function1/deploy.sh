#!/bin/bash

# Ensure the script stops if any command fails
set -e

gcloud auth activate-service-account --key-file="${SERVICE_ACCOUNT_KEY_PATH}"

# Set variables for deployment
FUNCTION_NAME="cloud_function1"
ENTRY_POINT="main"  # The function name to be used as the entry point in your Python script
REGION="asia-south1 (Mumbai)"  # e.g., us-central1
PROJECT_ID="devops-testing-419206"
RUNTIME="python39"  # Python runtime version

# Deploy the function
gcloud functions deploy $FUNCTION_NAME \
    --entry-point $ENTRY_POINT \
    --runtime $RUNTIME \
    --trigger-http \
    --allow-unauthenticated \
    --region $REGION \
    --project $PROJECT_ID

# Check deployment status
if [ $? -eq 0 ]; then
    echo "Deployment successful for function: $FUNCTION_NAME"
else
    echo "Deployment failed for function: $FUNCTION_NAME"
    exit 1
fi
