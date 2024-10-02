#!/bin/bash

# Check if PROJECT_NAME argument is passed
if [ -z "$1" ]; then
  echo "Usage: $0 PROJECT_NAME"
  exit 1
fi

PROJECT_NAME="$1"
BUCKET_NAME="$PROJECT_NAME"
ADMIN_EMAIL="dlab-admin@berkeley.edu"
OWNER_EMAIL="aculich@berkeley.edu"
EXISTING_PROJECT="dlab-testing-1234"
DIRECTORY="dist"

# Function to check if a service is enabled
check_service_enabled() {
  local SERVICE=$1
  local PROJECT=$2
  gcloud services list --enabled --filter="config.name:$SERVICE" --project="$PROJECT" --format="value(config.name)" > /dev/null 2>&1
}

# Function to enable a service
enable_service() {
  local SERVICE=$1
  local PROJECT=$2
  if ! check_service_enabled "$SERVICE" "$PROJECT"; then
    echo "Enabling $SERVICE for project $PROJECT..."
    gcloud services enable "$SERVICE" --project="$PROJECT"
  else
    echo "$SERVICE is already enabled for project $PROJECT."
  fi
}

# Check if the project already exists
EXISTING_PROJECT_CHECK=$(gcloud projects list --filter="PROJECT_ID=$PROJECT_NAME" --format="value(projectId)")

if [ "$EXISTING_PROJECT_CHECK" == "$PROJECT_NAME" ]; then
  echo "Project $PROJECT_NAME already exists. Continuing with setup..."
else
  # Get the parent of the existing project
  PARENT_ID=$(gcloud projects describe "$EXISTING_PROJECT" --format="value(parent.id)")
  PARENT_TYPE=$(gcloud projects describe "$EXISTING_PROJECT" --format="value(parent.type)")

  # Check if parent exists
  if [ -z "$PARENT_ID" ]; then
    echo "Unable to find parent for the project $EXISTING_PROJECT. Exiting."
    exit 1
  fi

  # Create a new GCP project under the same parent
  if [ "$PARENT_TYPE" == "folder" ]; then
    gcloud projects create "$PROJECT_NAME" --folder="$PARENT_ID" --set-as-default
  elif [ "$PARENT_TYPE" == "organization" ]; then
    gcloud projects create "$PROJECT_NAME" --organization="$PARENT_ID" --set-as-default
  else
    echo "Unknown parent type: $PARENT_TYPE. Exiting."
    exit 1
  fi
fi

# Set the project as the active project
gcloud config set project "$PROJECT_NAME"

# Add aculich@berkeley.edu as OWNER
gcloud projects add-iam-policy-binding "$PROJECT_NAME" \
  --member="user:$OWNER_EMAIL" \
  --role="roles/owner"

# Prompt the user to link the billing account manually
echo "Please link the billing account to the project $PROJECT_NAME in the Google Cloud Console."
read -p "Press [Enter] once the billing account has been linked to continue..."

# Enable necessary APIs
REQUIRED_SERVICES=(
  "appengine.googleapis.com"
  "iam.googleapis.com"
  "cloudresourcemanager.googleapis.com"
  "cloudidentity.googleapis.com"
  "iap.googleapis.com"
  "storage.googleapis.com"
  "cloudbuild.googleapis.com"
)

for SERVICE in "${REQUIRED_SERVICES[@]}"; do
  enable_service "$SERVICE" "$PROJECT_NAME"
done

# Set up App Engine
gcloud app create --region=us-central

# Delete and recreate the GCP bucket
gsutil rm -r "gs://$BUCKET_NAME/" || echo "Bucket does not exist, creating a new one."
gsutil mb -p "$PROJECT_NAME" "gs://$BUCKET_NAME/"

# Build the project (Assumes build has already been done; skipping npm install)
# Replace "Hello Framework" with PROJECT_NAME in HTML files
replace_title_in_html() {
  find "$DIRECTORY" -name "*.html" -exec sed -i '' "s/Hello Framework/$PROJECT_NAME/g" {} +
}

replace_title_in_html

# Copy the build files to the bucket from the specified directory
gsutil -m cp -r "$DIRECTORY"/* "gs://$BUCKET_NAME/"

# Create an IAP access policy
gcloud iap web enable --resource-type=app-engine
gcloud iap web add-iam-policy-binding \
  --resource-type=app-engine \
  --member=user:"$ADMIN_EMAIL" \
  --role=roles/iap.httpsResourceAccessor

# Deploy the App Engine application
gcloud app deploy --quiet

# Deny access to all users except the admin
gcloud projects add-iam-policy-binding "$PROJECT_NAME" \
  --member="allAuthenticatedUsers" \
  --role="roles/viewer" || echo "Failed to add viewer role to allAuthenticatedUsers"

gcloud projects remove-iam-policy-binding "$PROJECT_NAME" \
  --member="allAuthenticatedUsers" \
  --role="roles/iap.httpsResourceAccessor" || echo "Failed to remove IAP access from allAuthenticatedUsers"

gcloud projects add-iam-policy-binding "$PROJECT_NAME" \
  --member="user:$ADMIN_EMAIL" \
  --role="roles/iap.httpsResourceAccessor"

echo "Project $PROJECT_NAME created and configured. Only $ADMIN_EMAIL has access."
