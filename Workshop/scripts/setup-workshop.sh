#!/bin/bash

# DevOps Workshop Setup Script
# This script sets up the complete workshop environment

set -e

echo "🚀 DevOps Bootcamp - IaC and Observability Workshop Setup"
echo "=========================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
print_status "Checking prerequisites..."

# Check Docker
if command_exists docker; then
    if docker info >/dev/null 2>&1; then
        print_success "Docker is running"
    else
        print_error "Docker is installed but not running. Please start Docker."
        exit 1
    fi
else
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check kubectl
if command_exists kubectl; then
    print_success "kubectl is installed"
else
    print_error "kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check Terraform
if command_exists terraform; then
    print_success "Terraform is installed"
else
    print_error "Terraform is not installed. Please install Terraform first."
    exit 1
fi

# Check Helm
if command_exists helm; then
    print_success "Helm is installed"
else
    print_warning "Helm is not installed. Installing Helm..."
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    rm get_helm.sh
    print_success "Helm installed successfully"
fi

print_status "All prerequisites are satisfied!"

# Setup workshop
echo ""
print_status "Setting up workshop environment..."

# Step 1: Create Kubernetes cluster
echo ""
print_status "Step 1: Creating Kubernetes cluster with Kind..."
cd 02-terraform-k8s
cp terraform.tfvars.example terraform.tfvars

terraform init -upgrade
terraform plan -out=tfplan
terraform apply tfplan

if [ $? -eq 0 ]; then
    print_success "Kubernetes cluster created successfully"
else
    print_error "Failed to create Kubernetes cluster"
    exit 1
fi

# Wait for cluster to be ready
print_status "Waiting for cluster to be ready..."
kubectl wait --for=condition=ready node --all --timeout=300s

# Step 2: Deploy application
echo ""
print_status "Step 2: Deploying sample application..."
cd ../03-app-deployment
cp terraform.tfvars.example terraform.tfvars

terraform init -upgrade
terraform plan -out=tfplan
terraform apply tfplan

if [ $? -eq 0 ]; then
    print_success "Sample application deployed successfully"
else
    print_error "Failed to deploy sample application"
    exit 1
fi

# Wait for application to be ready
print_status "Waiting for application pods to be ready..."
kubectl wait --for=condition=ready pod -l app=sample-app -n devops-app --timeout=300s

# Step 3: Deploy monitoring stack
echo ""
print_status "Step 3: Deploying monitoring stack (this may take a few minutes)..."
cd ../05-monitoring-stack

# Add Helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

cp terraform.tfvars.example terraform.tfvars

terraform init -upgrade
terraform plan -out=tfplan
terraform apply tfplan

if [ $? -eq 0 ]; then
    print_success "Monitoring stack deployed successfully"
else
    print_error "Failed to deploy monitoring stack"
    exit 1
fi

# Wait for monitoring stack to be ready
print_status "Waiting for monitoring stack to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n monitoring --timeout=600s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n monitoring --timeout=600s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=loki -n monitoring --timeout=600s

# Step 4: Generate some traffic
echo ""
print_status "Step 4: Generating sample traffic..."
for i in {1..20}; do
    curl -s http://localhost/ >/dev/null || true
    curl -s http://localhost/health >/dev/null || true
    curl -s http://localhost/info >/dev/null || true
    sleep 1
done

print_success "Sample traffic generated"

# Final setup information
echo ""
echo "🎉 Workshop setup complete!"
echo "=========================="
echo ""
echo "📋 Access Information:"
echo "----------------------"

# Get Grafana password
GRAFANA_PASSWORD=$(kubectl get secret grafana -o jsonpath="{.data.admin-password}" -n monitoring | base64 -d)

echo "🎯 Application URL: http://localhost"
echo "📊 Grafana URL: http://localhost:3000"
echo "   Username: admin"
echo "   Password: $GRAFANA_PASSWORD"
echo "📈 Prometheus URL: http://localhost:9090"
echo ""
echo "🚀 To access services:"
echo "----------------------"
echo "# Access Grafana:"
echo "kubectl port-forward service/grafana 3000:80 -n monitoring"
echo ""
echo "# Access Prometheus:"
echo "kubectl port-forward service/prometheus-server 9090:80 -n monitoring"
echo ""
echo "# View application logs:"
echo "kubectl logs -l app=sample-app -n devops-app -f"
echo ""
echo "# Check all pods:"
echo "kubectl get pods --all-namespaces"
echo ""

print_success "🎉 Ready to start the workshop! Follow the README.md for guided tasks."

cd ..
