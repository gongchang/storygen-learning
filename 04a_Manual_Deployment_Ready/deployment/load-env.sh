#!/bin/bash
#
# This script loads environment variables from the .env file.
# It is intended to be sourced by other deployment scripts.

set -a # Automatically export all variables
if [ -f "../.env" ]; then
    source ../.env
else
    echo "Error: .env file not found in parent directory."
    exit 1
fi
set +a

# Validate that essential variables are set
: "${GCP_PROJECT_ID:?GCP_PROJECT_ID not set or empty}"
: "${GCP_REGION:?GCP_REGION not set or empty}"
: "${GCP_SERVICE_ACCOUNT_NAME:?GCP_SERVICE_ACCOUNT_NAME not set or empty}"
: "${GCP_ARTIFACT_REGISTRY_REPOSITORY:?GCP_ARTIFACT_REGISTRY_REPOSITORY not set or empty}"
: "${GCP_STORAGE_BUCKET_NAME:?GCP_STORAGE_BUCKET_NAME not set or empty}"

echo "✅ Environment variables loaded."
