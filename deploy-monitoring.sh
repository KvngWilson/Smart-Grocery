#!/bin/bash

# Deploy monitoring stack to Kubernetes

set -e

echo "🔍 Deploying Prometheus & Grafana Monitoring Stack"
echo "===================================================="
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed"
    exit 1
fi

# Check if namespace exists
if ! kubectl get namespace smart-grocery &> /dev/null; then
    echo "Creating smart-grocery namespace..."
    kubectl create namespace smart-grocery
fi

echo "Step 1: Deploying Prometheus..."
echo "================================"
kubectl apply -f k8s/prometheus-config.yaml
kubectl apply -f k8s/prometheus-deployment.yaml
echo "✅ Prometheus deployed"
echo ""

echo "Step 2: Deploying Grafana..."
echo "============================="
kubectl apply -f k8s/grafana-config.yaml
kubectl apply -f k8s/grafana-deployment.yaml
echo "✅ Grafana deployed"
echo ""

echo "Step 3: Deploying Redis Exporter..."
echo "===================================="
kubectl apply -f k8s/redis-exporter.yaml
echo "✅ Redis Exporter deployed"
echo ""

echo "Step 4: Waiting for pods to be ready..."
echo "========================================"
kubectl wait --for=condition=ready pod -l app=prometheus -n smart-grocery --timeout=120s
kubectl wait --for=condition=ready pod -l app=grafana -n smart-grocery --timeout=120s
kubectl wait --for=condition=ready pod -l app=redis-exporter -n smart-grocery --timeout=120s
echo "✅ All pods are ready"
echo ""

echo "Step 5: Getting Access Information..."
echo "======================================"
PROMETHEUS_POD=$(kubectl get pod -n smart-grocery -l app=prometheus -o jsonpath='{.items[0].metadata.name}')
GRAFANA_SVC=$(kubectl get svc grafana -n smart-grocery -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")

echo ""
echo "✅ Deployment Complete!"
echo ""
echo "Access your monitoring stack:"
echo "=============================="
echo ""
echo "📊 Prometheus:"
echo "  Port Forward: kubectl port-forward -n smart-grocery $PROMETHEUS_POD 9090:9090"
echo "  Then visit: http://localhost:9090"
echo ""
echo "📈 Grafana:"
if [ "$GRAFANA_SVC" != "pending" ]; then
    echo "  External IP: http://$GRAFANA_SVC:3000"
else
    echo "  Port Forward: kubectl port-forward -n smart-grocery svc/grafana 3000:3000"
    echo "  Then visit: http://localhost:3000"
fi
echo "  Default Credentials:"
echo "    Username: admin"
echo "    Password: admin123"
echo ""
echo "🔍 Redis Metrics:"
echo "  Available at: http://prometheus:9090/targets"
echo ""
echo "📋 Useful Commands:"
echo "==================="
echo "  View all monitoring pods:"
echo "    kubectl get pods -n smart-grocery -l 'app in (prometheus,grafana,redis-exporter)'"
echo ""
echo "  View Prometheus logs:"
echo "    kubectl logs -n smart-grocery -l app=prometheus -f"
echo ""
echo "  View Grafana logs:"
echo "    kubectl logs -n smart-grocery -l app=grafana -f"
echo ""
echo "  Delete monitoring stack:"
echo "    kubectl delete -f k8s/prometheus-deployment.yaml"
echo "    kubectl delete -f k8s/grafana-deployment.yaml"
echo "    kubectl delete -f k8s/redis-exporter.yaml"
echo ""
