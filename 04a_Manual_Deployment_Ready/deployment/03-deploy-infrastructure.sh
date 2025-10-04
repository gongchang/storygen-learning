#!/bin/bash
#
# This script deploys the infrastructure using Terraform and
# deploys the frontend and backend services to Cloud Run.

set -e

# Source environment variables
source ./load-env.sh

LOCATION=$GCP_REGION
PROJECT_ID=$GCP_PROJECT_ID
REPOSITORY=$GCP_ARTIFACT_REGISTRY_REPOSITORY

BACKEND_IMAGE_URI="${LOCATION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/storygen-backend:latest"
FRONTEND_IMAGE_URI="${LOCATION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/storygen-frontend:latest"

echo "### Step 1: Deploying infrastructure with Terraform ###"
cd ../terraform_code

terraform init

# The -var flags pass variables to your Terraform configuration.
terraform apply -auto-approve \
  -var="project_id=$GCP_PROJECT_ID" \
  -var="region=$GCP_REGION" \
  -var="service_account_name=$GCP_SERVICE_ACCOUNT_NAME" \
  -var="artifact_registry_repository_name=$GCP_ARTIFACT_REGISTRY_REPOSITORY" \
  -var="storage_bucket_name=$GCP_STORAGE_BUCKET_NAME" \
  -var="backend_image_uri=$BACKEND_IMAGE_URI" \
  -var="frontend_image_uri=$FRONTEND_IMAGE_URI"


# Get Terraform outputs for service URIs
FRONTEND_URL=$(terraform output -raw frontend-service_service_uri)
BACKEND_URL=$(terraform output -raw backend-service_service_uri)

cd ../deployment

echo "### Step 2: Updating frontend environment variables ###"
# Create or update the .env.production file in the frontend directory
cat <<EOF > ../frontend/.env.production
NEXT_PUBLIC_BACKEND_URL=$BACKEND_URL
EOF

echo "### Step 3: Re-building and pushing the frontend image with updated environment ###"
# Since the frontend URL depends on the backend, we rebuild the frontend image
# after the backend is deployed and the URL is known.
docker build -t $FRONTEND_IMAGE_URI ../frontend
docker push $FRONTEND_IMAGE_URI

echo "### Step 4: Redeploying frontend service to Cloud Run with new image ###"
FRONTEND_SERVICE_NAME="storygen-frontend"
gcloud run deploy $FRONTEND_SERVICE_NAME \
  --image=$FRONTEND_IMAGE_URI \
  --platform=managed \
  --region=${GCP_REGION} \
  --allow-unauthenticated \
  --service-account="${GCP_SERVICE_ACCOUNT_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com"

echo "✅ Deployment complete."
echo "🚀 Frontend is available at: $FRONTEND_URL"
