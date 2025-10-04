# StoryGen CI/CD Pipeline

This document describes the CI/CD pipeline for the StoryGen application, which is composed of a backend and a frontend.

## Pipeline Overview

The CI/CD pipeline is built using Google Cloud Build and GitHub Actions. It automates the process of building, testing, and deploying the application.

### Technologies Used

*   **Google Cloud Build:** For building Docker images and deploying to Google Cloud Run.
*   **Google Artifact Registry:** For storing Docker images.
*   **Google Cloud Run:** for hosting the backend and frontend services.
*   **Google Secret Manager:** For managing secrets.
*   **GitHub Actions:** For triggering the Cloud Build pipeline.

## Backend Pipeline

The backend pipeline is defined in the `cloudbuild.yaml` file. It consists of the following steps:

1.  **Build Docker Image:** Builds the Docker image for the backend application using the `backend/Dockerfile`.
2.  **Push to Artifact Registry:** Pushes the built Docker image to a repository in Google Artifact Registry.
3.  **Deploy to Cloud Run:** Deploys the image to a Google Cloud Run service named `storygen-backend`.

### How to Trigger the Pipeline

The pipeline is automatically triggered on every push to the `main` branch of the GitHub repository. This is configured in the `.github/workflows/cloud-build.yml` file.

### Environment-specific Deployments

The pipeline supports the concept of staging and production environments.

*   **Staging:** The `cloudbuild.yaml` file deploys to a service named `storygen-backend`, which can be considered the staging environment.
*   **Production:** A `scripts/promote.sh` script is provided to promote a specific image from the staging environment to the production environment. The production service is named `storygen-backend-prod`.

To promote an image to production, run the following command:

```bash
./scripts/promote.sh <image_tag>
```

### Secret Management

The pipeline uses Google Secret Manager to manage the `GOOGLE_API_KEY` secret. The Cloud Run service is configured to access this secret.

### Notifications

The `cloudbuild.yaml` file includes a commented-out section for setting up notifications to a Google Chat space on build failure. To enable this, you need to:

1.  Create a Google Chat space and a webhook.
2.  Store the webhook URL in Secret Manager.
3.  Create a Cloud Build notifier configuration.

## Frontend Pipeline

The frontend pipeline is not yet implemented. However, a similar pipeline can be created for the frontend using the existing `frontend/Dockerfile` and `frontend/cloudbuild.yaml`.
