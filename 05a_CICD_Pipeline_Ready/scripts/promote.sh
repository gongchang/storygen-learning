#!/bin/bash

set -e

# Usage: ./promote.sh <image_tag>
# Example: ./promote.sh 1.0.0

if [ -z "$1" ]; then
  echo "Error: Image tag not provided."
  echo "Usage: ./promote.sh <image_tag>"
  exit 1
fi

IMAGE_TAG=$1
PROJECT_ID=$(gcloud config get-value project)
REGION="us-central1"
PROD_SERVICE_NAME="storygen-backend-prod"
STAGING_IMAGE="us-central1-docker.pkg.dev/${PROJECT_ID}/storygen/storygen-backend:${IMAGE_TAG}"

echo "Promoting image ${STAGING_IMAGE} to production..."

gcloud run deploy ${PROD_SERVICE_NAME} \
  --image=${STAGING_IMAGE} \
  --region=${REGION} \
  --platform=managed \
  --allow-unauthenticated \
  --port=8080 \
  --set-env-vars=FRONTEND_URL=<PROD_FRONTEND_URL> \
  --set-secrets=GOOGLE_API_KEY=storygen-google-api-key:latest

echo "Promotion complete."

