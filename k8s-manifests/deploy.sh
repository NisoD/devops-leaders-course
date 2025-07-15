#!/bin/bash

# Deploy DevOps Leaders App to Kubernetes using plain manifests
# This script applies all the Kubernetes manifests in order

set -e

# Configuration
NAMESPACE="devops-leaders"
IMAGE_NAME="devops-leaders-app:latest"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed. Please install it first."
    exit 1
fi

# Create namespace if it doesn't exist
print_status "Creating namespace: ${NAMESPACE}"
kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

# Apply manifests in order
print_status "Applying ConfigMap..."
kubectl apply -f configmap.yaml -n ${NAMESPACE}

print_status "Applying Service..."
kubectl apply -f service.yaml -n ${NAMESPACE}

print_status "Applying Deployment..."
kubectl apply -f deployment.yaml -n ${NAMESPACE}

# Wait for deployment to be ready
print_status "Waiting for deployment to be ready..."
kubectl wait --for=condition=available deployment/devops-leaders-app-deployment -n ${NAMESPACE} --timeout=300s

# Get status
print_status "Deployment status:"
kubectl get pods -n ${NAMESPACE}
kubectl get svc -n ${NAMESPACE}

print_status "Deployment completed successfully!"
echo ""
echo "To access the application:"
echo "kubectl port-forward service/devops-leaders-app-service 8080:80 -n ${NAMESPACE}"
echo ""
echo "Then open your browser to: http://localhost:8080" 