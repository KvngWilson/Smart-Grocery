#!/bin/bash

set -e

echo "======================================"
echo "Smart Grocery - GCP Terraform Deploy"
echo "======================================"
echo ""

# Check prerequisites
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install Terraform first."
    exit 1
fi

if ! command -v gcloud &> /dev/null; then
    echo "❌ Google Cloud SDK (gcloud) is not installed. Please install it first."
    exit 1
fi

# Set environment (default to dev)
ENVIRONMENT="${1:-dev}"

if [ "$ENVIRONMENT" != "dev" ] && [ "$ENVIRONMENT" != "prod" ]; then
    echo "❌ Invalid environment. Use 'dev' or 'prod'"
    exit 1
fi

echo "🚀 Deploying to: $ENVIRONMENT"
echo ""

# Get current GCP project
CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null)
echo "Current GCP Project: $CURRENT_PROJECT"
echo ""

# Confirm deployment
read -p "Do you want to continue? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Deployment cancelled."
    exit 0
fi

cd terraform

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init -upgrade

# Validate configuration
echo "✅ Validating Terraform configuration..."
terraform validate

# Plan deployment
echo "📋 Planning deployment..."
terraform plan -var-file="environments/$ENVIRONMENT/terraform.tfvars" -out=tfplan

echo ""
echo "Review the plan above."
read -p "Apply this plan? (yes/no): " APPLY
if [ "$APPLY" != "yes" ]; then
    echo "Deployment cancelled."
    rm -f tfplan
    exit 0
fi

# Apply deployment
echo "🚀 Applying Terraform configuration..."
terraform apply tfplan

rm -f tfplan

echo ""
echo "✅ Infrastructure deployment complete!"
echo ""

# Get cluster credentials
echo "📥 Configuring kubectl..."
CLUSTER_NAME=$(terraform output -raw cluster_name)
REGION=$(terraform output -raw region)
PROJECT_ID=$(terraform output -raw project_id)

gcloud container clusters get-credentials "$CLUSTER_NAME" --region "$REGION" --project "$PROJECT_ID"

echo ""
echo "🎉 GCP Infrastructure is ready!"
echo ""
echo "Next steps:"
echo "1. Build and push Docker images:"
echo "   ./gcp-build-push.sh"
echo ""
echo "2. Deploy the application:"
echo "   kubectl apply -k k8s/"
echo ""
echo "3. Check status:"
echo "   kubectl get all -n smart-grocery"
echo ""
