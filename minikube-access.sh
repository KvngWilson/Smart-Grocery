#!/bin/bash

# Minikube Access Script for Smart Grocery Manager

echo "🚀 Smart Grocery Manager - Minikube Access"
echo "==========================================="
echo ""

# Check if minikube is running
if ! minikube status | grep -q "Running"; then
    echo "❌ Minikube is not running. Start it with: minikube start"
    exit 1
fi

echo "✅ Minikube is running"
echo ""

# Get service URLs
echo "📍 Service URLs:"
echo "==============="
echo ""

echo "🛒 Application (Client):"
APP_URL=$(minikube service client -n smart-grocery --url 2>/dev/null | head -1)
echo "   $APP_URL"
echo ""

echo "📈 Grafana (Monitoring Dashboard):"
GRAFANA_URL=$(minikube service grafana -n smart-grocery --url 2>/dev/null | head -1)
echo "   $GRAFANA_URL"
echo "   Username: admin"
echo "   Password: admin123"
echo ""

echo "📊 Prometheus (Metrics):"
echo "   kubectl port-forward -n smart-grocery svc/prometheus 9090:9090"
echo "   Then visit: http://localhost:9090"
echo ""

echo "🔍 Application Metrics:"
echo "   kubectl port-forward -n smart-grocery svc/server 5000:5000"
echo "   Then visit: http://localhost:5000/metrics"
echo ""

echo "📋 Useful Commands:"
echo "==================="
echo ""
echo "View all resources:"
echo "  kubectl get all -n smart-grocery"
echo ""
echo "View logs:"
echo "  kubectl logs -n smart-grocery -l app=server -f"
echo "  kubectl logs -n smart-grocery -l app=client -f"
echo ""
echo "Access pod shell:"
echo "  kubectl exec -it -n smart-grocery deployment/server -- sh"
echo ""
echo "Scale deployments:"
echo "  kubectl scale deployment/server --replicas=3 -n smart-grocery"
echo ""
echo "Restart deployments:"
echo "  kubectl rollout restart deployment/server -n smart-grocery"
echo ""
echo "Delete all resources:"
echo "  kubectl delete namespace smart-grocery"
echo ""
echo "Stop Minikube:"
echo "  minikube stop"
echo ""
echo "Delete Minikube cluster:"
echo "  minikube delete"
echo ""

# Open services in browser (optional)
read -p "Open services in browser? (y/n): " open_browser
if [ "$open_browser" = "y" ]; then
    echo ""
    echo "Opening services..."
    minikube service client -n smart-grocery &
    minikube service grafana -n smart-grocery &
    echo "Services opened in browser!"
fi

echo ""
echo "✨ Ready to use!"
