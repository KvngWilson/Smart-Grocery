#!/bin/bash

set -e

echo "======================================"
echo "Build & Push Docker Images to GCR"
echo "======================================"
echo ""

# Check prerequisites
if ! command -v gcloud &> /dev/null; then
    echo "❌ Google Cloud SDK (gcloud) is not installed."
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed."
    exit 1
fi

# Get GCP project ID
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)

if [ -z "$PROJECT_ID" ]; then
    echo "❌ No GCP project configured. Run: gcloud config set project PROJECT_ID"
    exit 1
fi

echo "📦 Building for project: $PROJECT_ID"
echo ""

# Configure Docker for GCR
echo "🔐 Configuring Docker for GCR..."
gcloud auth configure-docker gcr.io --quiet

# Build server image
echo "🏗️  Building server image..."
docker build -f Dockerfile.server -t gcr.io/$PROJECT_ID/smart-grocery-server:latest .
echo "✅ Server image built"

# Build client image
echo "🏗️  Building client image..."
docker build -f Dockerfile.client -t gcr.io/$PROJECT_ID/smart-grocery-client:latest .
echo "✅ Client image built"

# Push server image
echo "📤 Pushing server image to GCR..."
docker push gcr.io/$PROJECT_ID/smart-grocery-server:latest
echo "✅ Server image pushed"

# Push client image
echo "📤 Pushing client image to GCR..."
docker push gcr.io/$PROJECT_ID/smart-grocery-client:latest
echo "✅ Client image pushed"

echo ""
echo "✅ All images pushed successfully!"
echo ""
echo "Image URLs:"
echo "  Server: gcr.io/$PROJECT_ID/smart-grocery-server:latest"
echo "  Client: gcr.io/$PROJECT_ID/smart-grocery-client:latest"
echo ""
echo "Next steps:"
echo "1. Update k8s manifests to use these images"
echo "2. Deploy to GKE:"
echo "   kubectl apply -k k8s/"
echo ""
