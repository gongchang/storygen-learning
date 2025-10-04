#!/bin/bash
#
# This script builds the Docker images for the frontend and backend
# and pushes them to Google Artifact Registry.

set -e

# Source environment variables
source ./load-env.sh

LOCATION=$GCP_REGION
REPOSITORY=$GCP_ARTIFACT_REGISTRY_REPOSITORY
PROJECT_ID=$GCP_PROJECT_ID

BACKEND_IMAGE_NAME="${LOCATION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/storygen-backend:latest"
FRONTEND_IMAGE_NAME="${LOCATION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/storygen-frontend:latest"

echo "### Step 1: Configuring Docker authentication ###"
gcloud auth configure-docker ${LOCATION}-docker.pkg.dev

echo "### Step 2: Building backend Docker image ###"
docker build -t $BACKEND_IMAGE_NAME ../backend

echo "### Step 3: Building frontend Docker image ###"
docker build -t $FRONTEND_IMAGE_NAME ../frontend

echo "### Step 4: Pushing images to Artifact Registry ###"
docker push $BACKEND_IMAGE_NAME
docker push $FRONTEND_IMAGE_NAME

echo "✅ Docker images built and pushed successfully."
