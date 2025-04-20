#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ID="blacksmith-443107"
BUCKET_NAME="blacksmith-prompt-engineering"

# Verify correct project is set
CURRENT_PROJECT=$(gcloud config get-value project)
if [ "$CURRENT_PROJECT" != "$PROJECT_ID" ]; then
    echo -e "${RED}Warning: Current project ($CURRENT_PROJECT) does not match expected project ($PROJECT_ID)${NC}"
    read -p "Would you like to switch to the correct project? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        gcloud config set project $PROJECT_ID
        echo -e "${GREEN}Project switched to $PROJECT_ID${NC}"
    fi
fi

echo -e "${YELLOW}=== GCloud Authentication Status ===${NC}"
echo "Currently authenticated accounts:"
gcloud auth list
echo "Active account:"
gcloud config get-value account

# Add check for access token
echo -e "\nChecking for valid access token..."
if gcloud auth print-access-token >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Valid access token found${NC}"
else
    echo -e "${RED}✗ No valid access token${NC}"
    echo "Please run: gcloud auth login"
    exit 1
fi

# Add check for application default credentials
echo -e "\nChecking application default credentials..."
if gcloud auth application-default print-access-token >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Valid application default credentials found${NC}"
else
    echo -e "${RED}✗ No valid application default credentials${NC}"
    echo "Please run: gcloud auth application-default login"
    exit 1
fi

echo -e "\n${YELLOW}=== Project Configuration ===${NC}"
echo "Current project:"
gcloud config get-value project

echo -e "\n${YELLOW}=== Testing Bucket Access ===${NC}"
echo "Attempting to list bucket contents..."
if gsutil ls gs://${BUCKET_NAME}/ ; then
    echo -e "${GREEN}✓ Can list bucket contents${NC}"
else
    echo -e "${RED}✗ Cannot list bucket contents${NC}"
fi

echo -e "\n${YELLOW}=== Testing Write Permissions ===${NC}"
echo "Creating test file..."
echo "test content" > test.txt

echo "Attempting to upload test file..."
if gsutil cp test.txt gs://${BUCKET_NAME}/test.txt ; then
    echo -e "${GREEN}✓ Can upload to bucket${NC}"
else
    echo -e "${RED}✗ Cannot upload to bucket${NC}"
fi

echo "Attempting to delete test file..."
if gsutil rm gs://${BUCKET_NAME}/test.txt ; then
    echo -e "${GREEN}✓ Can delete from bucket${NC}"
else
    echo -e "${RED}✗ Cannot delete from bucket${NC}"
fi

# Clean up local test file
rm test.txt

echo -e "\n${YELLOW}=== Bucket IAM Policies ===${NC}"
echo "Fetching bucket IAM policies..."
gcloud storage buckets get-iam-policy gs://${BUCKET_NAME}

echo -e "\n${YELLOW}=== Service Account Check ===${NC}"
ACTIVE_ACCOUNT=$(gcloud auth list --format="value(account)" --filter="status=ACTIVE")
if [[ $ACTIVE_ACCOUNT == *"gserviceaccount.com" ]]; then
    echo -e "${GREEN}✓ Using service account: $ACTIVE_ACCOUNT${NC}"
else
    echo -e "${YELLOW}! Using user account: $ACTIVE_ACCOUNT${NC}"
    echo "Note: For CI/CD operations, a service account is recommended"
fi

echo -e "\n${YELLOW}=== Service Account Roles ===${NC}"
echo "Note: Skipping IAM policy check - requires additional permissions"

echo -e "\n${YELLOW}=== Checking Specific Storage Permissions ===${NC}"
echo "Testing storage permissions through direct operations..."
if gsutil ls gs://${BUCKET_NAME}/ >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Has bucket read permission${NC}"
else
    echo -e "${RED}✗ Lacks bucket read permission${NC}"
fi

if [ -f "test.txt" ]; then
    if gsutil cp test.txt gs://${BUCKET_NAME}/test.txt >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Has bucket write permission${NC}"
        gsutil rm gs://${BUCKET_NAME}/test.txt >/dev/null 2>&1
    else
        echo -e "${RED}✗ Lacks bucket write permission${NC}"
    fi
fi

echo -e "\n${YELLOW}=== Summary ===${NC}"
echo "Project: ${PROJECT_ID}"
echo "Bucket: ${BUCKET_NAME}"
echo "Active Account: ${ACTIVE_ACCOUNT}"



# First, revoke all credentials to start fresh
gcloud auth revoke --all

# Then activate the service account
gcloud auth activate-service-account blacksmith-github-actions@blacksmith-443107.iam.gserviceaccount.com --key-file=./blacksmith-443107-cec4ce7dd867.json

# Configure gcloud to use service account credentials
gcloud config set account blacksmith-github-actions@blacksmith-443107.iam.gserviceaccount.com

# Verify the active account
gcloud config get-value account

# Now try the upload
gsutil cp -r ./*.yaml gs://blacksmith-prompt-engineering/
