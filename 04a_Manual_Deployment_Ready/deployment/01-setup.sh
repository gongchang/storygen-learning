#!/bin/bash
#
# This script handles initial environment setup and authentication
# with Google Cloud Platform.

set -e # Exit immediately if a command exits with a non-zero status.

# Source environment variables
source ./load-env.sh

echo "### Step 1: Configuring gcloud CLI ###"
gcloud config set project $GCP_PROJECT_ID
gcloud config set compute/region $GCP_REGION

echo "### Step 2: Authenticating with GCP ###"
# This command will use your application default credentials.
# Make sure you have authenticated with 'gcloud auth application-default login'.
gcloud auth application-default login

echo "### Step 3: Enabling required GCP services ###"
gcloud services enable \
  run.googleapis.com \
  artifactregistry.googleapis.com \
  iam.googleapis.com \
  cloudbuild.googleapis.com \
  aiplatform.googleapis.com \
  storage.googleapis.com

echo "✅ GCP setup complete."

