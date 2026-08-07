#!/bin/bash

set -e

echo "======================================"
echo "Cleaning up Smart Grocery Deployment"
echo "======================================"
echo ""

if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed."
    exit 1
fi

echo "🗑️  Deleting all resources..."
echo ""

# Delete namespace (this will delete all resources in it)
kubectl delete namespace smart-grocery --ignore-not-found=true

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "All resources have been removed from the cluster."
echo ""
