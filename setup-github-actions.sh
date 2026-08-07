#!/bin/bash

# GitHub Actions Setup Script
# This script helps configure GitHub secrets and GCP Workload Identity

set -e

echo "🤖 GitHub Actions Setup for Smart Grocery Manager"
echo "=================================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}❌ gcloud CLI is not installed${NC}"
    echo "Install from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${YELLOW}⚠️  gh CLI is not installed${NC}"
    echo "Install from: https://cli.github.com/"
    echo "You'll need to set secrets manually in GitHub UI"
    GH_INSTALLED=false
else
    GH_INSTALLED=true
fi

echo ""
echo "Step 1: Get GCP Project Information"
echo "===================================="

# Get current project
CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null)
if [ -n "$CURRENT_PROJECT" ]; then
    echo -e "${GREEN}Current GCP Project: $CURRENT_PROJECT${NC}"
    read -p "Use this project? (y/n): " use_current
    if [ "$use_current" = "y" ]; then
        PROJECT_ID=$CURRENT_PROJECT
    else
        read -p "Enter GCP Project ID: " PROJECT_ID
        gcloud config set project $PROJECT_ID
    fi
else
    read -p "Enter GCP Project ID: " PROJECT_ID
    gcloud config set project $PROJECT_ID
fi

# Get project number
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
echo -e "${GREEN}✓ Project Number: $PROJECT_NUMBER${NC}"

echo ""
echo "Step 2: Get GitHub Repository Information"
echo "=========================================="

if [ "$GH_INSTALLED" = true ]; then
    REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")
    if [ -n "$REPO" ]; then
        echo -e "${GREEN}Detected Repository: $REPO${NC}"
    else
        read -p "Enter GitHub repository (username/repo-name): " REPO
    fi
else
    read -p "Enter GitHub repository (username/repo-name): " REPO
fi

echo ""
echo "Step 3: Create Service Account"
echo "==============================="

SERVICE_ACCOUNT_NAME="github-actions-sa"
SERVICE_ACCOUNT_EMAIL="$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"

# Check if service account exists
if gcloud iam service-accounts describe $SERVICE_ACCOUNT_EMAIL &>/dev/null; then
    echo -e "${YELLOW}⚠️  Service account already exists${NC}"
    read -p "Use existing service account? (y/n): " use_existing
    if [ "$use_existing" != "y" ]; then
        read -p "Enter new service account name: " SERVICE_ACCOUNT_NAME
        SERVICE_ACCOUNT_EMAIL="$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"
    fi
else
    echo "Creating service account: $SERVICE_ACCOUNT_NAME"
    gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
        --display-name="GitHub Actions Service Account" \
        --project=$PROJECT_ID
    echo -e "${GREEN}✓ Service account created${NC}"
fi

echo ""
echo "Step 4: Grant IAM Roles"
echo "======================="

ROLES=(
    "roles/container.developer"
    "roles/storage.admin"
    "roles/artifactregistry.writer"
    "roles/iam.serviceAccountUser"
)

for role in "${ROLES[@]}"; do
    echo "Granting $role..."
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
        --role="$role" \
        --quiet &>/dev/null
done

echo -e "${GREEN}✓ All roles granted${NC}"

echo ""
echo "Step 5: Set Up Workload Identity"
echo "================================="

POOL_NAME="github-pool"
PROVIDER_NAME="github-provider"

# Create Workload Identity Pool
if gcloud iam workload-identity-pools describe $POOL_NAME \
    --location="global" \
    --project=$PROJECT_ID &>/dev/null; then
    echo -e "${YELLOW}⚠️  Workload Identity Pool already exists${NC}"
else
    echo "Creating Workload Identity Pool..."
    gcloud iam workload-identity-pools create $POOL_NAME \
        --project=$PROJECT_ID \
        --location="global" \
        --display-name="GitHub Actions Pool"
    echo -e "${GREEN}✓ Pool created${NC}"
fi

# Create Workload Identity Provider
if gcloud iam workload-identity-pools providers describe $PROVIDER_NAME \
    --location="global" \
    --workload-identity-pool=$POOL_NAME \
    --project=$PROJECT_ID &>/dev/null; then
    echo -e "${YELLOW}⚠️  Provider already exists${NC}"
else
    echo "Creating Workload Identity Provider..."
    gcloud iam workload-identity-pools providers create-oidc $PROVIDER_NAME \
        --project=$PROJECT_ID \
        --location="global" \
        --workload-identity-pool=$POOL_NAME \
        --display-name="GitHub Provider" \
        --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
        --issuer-uri="https://token.actions.githubusercontent.com"
    echo -e "${GREEN}✓ Provider created${NC}"
fi

echo ""
echo "Step 6: Configure IAM Binding"
echo "=============================="

echo "Binding service account to GitHub repository..."
gcloud iam service-accounts add-iam-policy-binding \
    $SERVICE_ACCOUNT_EMAIL \
    --project=$PROJECT_ID \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/$POOL_NAME/attribute.repository/$REPO"

echo -e "${GREEN}✓ IAM binding complete${NC}"

echo ""
echo "Step 7: Generate Secrets"
echo "========================"

WORKLOAD_IDENTITY_PROVIDER="projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/$POOL_NAME/providers/$PROVIDER_NAME"

echo ""
echo "==================================="
echo "GitHub Secrets to Configure:"
echo "==================================="
echo ""
echo -e "${GREEN}GCP_PROJECT_ID${NC}"
echo "$PROJECT_ID"
echo ""
echo -e "${GREEN}GCP_SERVICE_ACCOUNT${NC}"
echo "$SERVICE_ACCOUNT_EMAIL"
echo ""
echo -e "${GREEN}GCP_WORKLOAD_IDENTITY_PROVIDER${NC}"
echo "$WORKLOAD_IDENTITY_PROVIDER"
echo ""

# Set secrets using gh CLI
if [ "$GH_INSTALLED" = true ]; then
    echo "Step 8: Set GitHub Secrets"
    echo "=========================="
    read -p "Do you want to set GitHub secrets now? (y/n): " set_secrets
    
    if [ "$set_secrets" = "y" ]; then
        echo "Setting GCP_PROJECT_ID..."
        echo "$PROJECT_ID" | gh secret set GCP_PROJECT_ID
        
        echo "Setting GCP_SERVICE_ACCOUNT..."
        echo "$SERVICE_ACCOUNT_EMAIL" | gh secret set GCP_SERVICE_ACCOUNT
        
        echo "Setting GCP_WORKLOAD_IDENTITY_PROVIDER..."
        echo "$WORKLOAD_IDENTITY_PROVIDER" | gh secret set GCP_WORKLOAD_IDENTITY_PROVIDER
        
        echo -e "${GREEN}✓ All secrets set successfully!${NC}"
    fi
else
    echo ""
    echo "Manual Setup Required:"
    echo "======================"
    echo "1. Go to: https://github.com/$REPO/settings/secrets/actions"
    echo "2. Click 'New repository secret'"
    echo "3. Add each of the above secrets"
fi

echo ""
echo "Step 9: Enable Required APIs"
echo "============================="

APIS=(
    "container.googleapis.com"
    "compute.googleapis.com"
    "artifactregistry.googleapis.com"
    "cloudbuild.googleapis.com"
    "storage-api.googleapis.com"
)

for api in "${APIS[@]}"; do
    echo "Enabling $api..."
    gcloud services enable $api --project=$PROJECT_ID
done

echo -e "${GREEN}✓ All APIs enabled${NC}"

echo ""
echo "Step 10: Create GitHub Environments"
echo "==================================="
echo ""
echo "Create the following environments in GitHub:"
echo "  - dev"
echo "  - prod"
echo "  - dev-destroy"
echo "  - prod-destroy"
echo ""
echo "URL: https://github.com/$REPO/settings/environments"
echo ""

echo ""
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo ""
echo "Next Steps:"
echo "==========="
echo "1. Verify secrets in GitHub: https://github.com/$REPO/settings/secrets/actions"
echo "2. Create environments: https://github.com/$REPO/settings/environments"
echo "3. Configure environment protection rules for 'prod'"
echo "4. Push code to trigger workflows"
echo ""
echo "Test your setup:"
echo "  git add ."
echo "  git commit -m 'Add GitHub Actions workflows'"
echo "  git push origin main"
echo ""
echo "View workflow runs:"
echo "  https://github.com/$REPO/actions"
echo ""
