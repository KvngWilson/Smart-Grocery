#!/bin/bash

set -e

echo "======================================"
echo "Smart Grocery - Helm Deployment"
echo "======================================"
echo ""

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    echo "❌ Helm is not installed. Please install Helm first."
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl first."
    exit 1
fi

echo "✓ Helm and kubectl are installed"
echo ""

# Build Docker images
echo "📦 Building Docker images..."
docker build -f Dockerfile.server -t smart-grocery-server:latest .
docker build -f Dockerfile.client -t smart-grocery-client:latest .
echo "✓ Images built"
echo ""

# Load images into local cluster if needed
if kubectl config current-context | grep -q "minikube"; then
    echo "📥 Loading images into Minikube..."
    minikube image load smart-grocery-server:latest
    minikube image load smart-grocery-client:latest
elif kubectl config current-context | grep -q "kind"; then
    echo "📥 Loading images into Kind..."
    kind load docker-image smart-grocery-server:latest
    kind load docker-image smart-grocery-client:latest
fi

# Deploy with Helm
echo "🚀 Deploying with Helm..."
helm upgrade --install smart-grocery ./helm/smart-grocery \
  --namespace smart-grocery \
  --create-namespace \
  --wait \
  --timeout 5m

echo ""
echo "✅ Deployment Complete!"
echo ""

# Show status
echo "📊 Deployment Status:"
kubectl get all -n smart-grocery

echo ""
echo "🌐 Access Information:"
echo "Run: ./k8s-port-forward.sh"
echo "Then access: http://localhost:8080"
echo ""
