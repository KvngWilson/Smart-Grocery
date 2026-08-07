#!/bin/bash

set -e

echo "======================================"
echo "Smart Grocery - Kubernetes Deployment"
echo "======================================"
echo ""

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster. Please check your configuration."
    exit 1
fi

echo "✓ kubectl is installed and cluster is accessible"
echo ""

# Build Docker images
echo "📦 Building Docker images..."
echo "-----------------------------------"

echo "Building server image..."
docker build -f Dockerfile.server -t smart-grocery-server:latest .

echo "Building client image..."
docker build -f Dockerfile.client -t smart-grocery-client:latest .

echo "✓ Docker images built successfully"
echo ""

# Load images into cluster (for local clusters like minikube/kind)
if kubectl config current-context | grep -q "minikube\|kind"; then
    echo "📥 Loading images into local cluster..."
    
    if kubectl config current-context | grep -q "minikube"; then
        minikube image load smart-grocery-server:latest
        minikube image load smart-grocery-client:latest
    elif kubectl config current-context | grep -q "kind"; then
        kind load docker-image smart-grocery-server:latest
        kind load docker-image smart-grocery-client:latest
    fi
    
    echo "✓ Images loaded into cluster"
    echo ""
fi

# Apply Kubernetes manifests
echo "🚀 Deploying to Kubernetes..."
echo "-----------------------------------"

kubectl apply -f k8s/namespace.yaml
echo "✓ Namespace created"

kubectl apply -f k8s/configmap.yaml
echo "✓ ConfigMap created"

kubectl apply -f k8s/redis-pv.yaml
echo "✓ Redis PersistentVolume and PVC created"

kubectl apply -f k8s/redis-deployment.yaml
echo "✓ Redis deployed"

# Wait for Redis to be ready
echo "⏳ Waiting for Redis to be ready..."
kubectl wait --for=condition=ready pod -l app=redis -n smart-grocery --timeout=120s

kubectl apply -f k8s/server-deployment.yaml
echo "✓ Server deployed"

# Wait for Server to be ready
echo "⏳ Waiting for Server to be ready..."
kubectl wait --for=condition=ready pod -l app=server -n smart-grocery --timeout=120s

kubectl apply -f k8s/client-deployment.yaml
echo "✓ Client deployed"

# Wait for Client to be ready
echo "⏳ Waiting for Client to be ready..."
kubectl wait --for=condition=ready pod -l app=client -n smart-grocery --timeout=120s

kubectl apply -f k8s/hpa.yaml
echo "✓ HorizontalPodAutoscaler created"

# Optional: Apply Ingress if nginx-ingress controller is available
if kubectl get ingressclass nginx &> /dev/null; then
    kubectl apply -f k8s/ingress.yaml
    echo "✓ Ingress created"
else
    echo "⚠️  Nginx Ingress Controller not found. Skipping Ingress creation."
    echo "   You can access the app using port-forward or LoadBalancer IP."
fi

echo ""
echo "======================================"
echo "✅ Deployment Complete!"
echo "======================================"
echo ""

# Get service information
echo "📊 Service Status:"
echo "-----------------------------------"
kubectl get pods -n smart-grocery
echo ""
kubectl get services -n smart-grocery
echo ""

# Show access information
echo "🌐 Access Information:"
echo "-----------------------------------"

CLIENT_TYPE=$(kubectl get svc client -n smart-grocery -o jsonpath='{.spec.type}')

if [ "$CLIENT_TYPE" = "LoadBalancer" ]; then
    echo "Waiting for LoadBalancer IP..."
    sleep 5
    EXTERNAL_IP=$(kubectl get svc client -n smart-grocery -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    
    if [ -n "$EXTERNAL_IP" ]; then
        echo "Frontend: http://$EXTERNAL_IP"
    else
        echo "LoadBalancer IP pending. Use port-forward:"
        echo "kubectl port-forward -n smart-grocery svc/client 8080:80"
        echo "Then access: http://localhost:8080"
    fi
elif [ "$CLIENT_TYPE" = "NodePort" ]; then
    NODE_PORT=$(kubectl get svc client -n smart-grocery -o jsonpath='{.spec.ports[0].nodePort}')
    echo "Frontend: http://<NODE-IP>:$NODE_PORT"
else
    echo "Use port-forward to access the application:"
    echo ""
    echo "  kubectl port-forward -n smart-grocery svc/client 8080:80"
    echo "  kubectl port-forward -n smart-grocery svc/server 5000:5000"
    echo ""
    echo "Then access:"
    echo "  Frontend: http://localhost:8080"
    echo "  API:      http://localhost:5000"
fi

echo ""
echo "📋 Useful Commands:"
echo "-----------------------------------"
echo "View logs:     kubectl logs -f -l app=server -n smart-grocery"
echo "View pods:     kubectl get pods -n smart-grocery"
echo "Describe pod:  kubectl describe pod <pod-name> -n smart-grocery"
echo "Scale server:  kubectl scale deployment server --replicas=3 -n smart-grocery"
echo "Delete all:    kubectl delete namespace smart-grocery"
echo ""
