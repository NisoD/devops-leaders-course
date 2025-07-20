#!/bin/bash
# DevOps Workshop Setup Script
# This script sets up the entire workshop environment

set -e

echo "🚀 DevOps Workshop Setup Script"
echo "================================"

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

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Check if Docker is running
    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker."
        exit 1
    fi
    
    # Check Terraform
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    
    # Check Kind
    if ! command -v kind &> /dev/null; then
        print_error "Kind is not installed. Please install Kind first."
        print_error "macOS: brew install kind"
        print_error "Linux: curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64 && chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind"
        exit 1
    fi
    
    # Check Helm
    if ! command -v helm &> /dev/null; then
        print_warning "Helm is not installed. Installing Helm..."
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    fi
    
    print_success "All prerequisites are met!"
}

# Setup Kubernetes cluster
setup_cluster() {
    print_status "Setting up Kubernetes cluster..."
    
    cd 02-terraform-k8s
    
    # Copy terraform vars if not exists
    if [ ! -f terraform.tfvars ]; then
        cp terraform.tfvars.example terraform.tfvars
        print_status "Created terraform.tfvars from example"
    fi
    
    # Initialize and apply
    terraform init
    terraform plan
    terraform apply -auto-approve
    
    print_success "Kubernetes cluster is ready!"
    cd ..
}

# Deploy application
deploy_application() {
    print_status "Deploying sample application..."
    
    cd 03-app-deployment
    
    # Copy terraform vars if not exists
    if [ ! -f terraform.tfvars ]; then
        cp terraform.tfvars.example terraform.tfvars
        print_status "Created terraform.tfvars from example"
    fi
    
    # Initialize and apply
    terraform init
    terraform apply -auto-approve
    
    print_success "Application deployed successfully!"
    cd ..
}

# Setup monitoring stack
setup_monitoring() {
    print_status "Setting up monitoring stack..."
    
    # Add Helm repositories
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update
    
    cd 05-monitoring-stack
    
    # Copy terraform vars if not exists
    if [ ! -f terraform.tfvars ]; then
        cp terraform.tfvars.example terraform.tfvars
        print_status "Created terraform.tfvars from example"
    fi
    
    # Initialize and apply
    terraform init
    terraform apply -auto-approve
    
    print_success "Monitoring stack deployed successfully!"
    cd ..
}

# Wait for pods to be ready
wait_for_pods() {
    print_status "Waiting for all pods to be ready..."
    
    # Wait for application pods
    kubectl wait --for=condition=ready pod -l app=sample-app -n devops-app --timeout=300s
    
    # Wait for monitoring pods
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n monitoring --timeout=300s
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n monitoring --timeout=300s
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=loki -n monitoring --timeout=300s
    
    print_success "All pods are ready!"
}

# Generate sample traffic
generate_traffic() {
    print_status "Generating sample traffic..."
    
    # Port forward application
    kubectl port-forward service/sample-app-service 8080:80 -n devops-app &
    APP_PF_PID=$!
    
    sleep 5
    
    # Generate traffic
    for i in {1..50}; do
        curl -s http://localhost:8080/ > /dev/null
        curl -s http://localhost:8080/health > /dev/null
        curl -s http://localhost:8080/info > /dev/null
        sleep 0.1
    done
    
    # Stop port forward
    kill $APP_PF_PID 2>/dev/null || true
    
    print_success "Sample traffic generated!"
}

# Display access information
show_access_info() {
    print_success "Workshop setup completed!"
    echo ""
    echo "🎯 Access Information:"
    echo "====================="
    
    echo ""
    echo "📊 Grafana Dashboard:"
    echo "  Command: kubectl port-forward service/grafana 3000:80 -n monitoring"
    echo "  URL: http://localhost:3000"
    echo "  Username: admin"
    echo "  Password: admin123"
    
    echo ""
    echo "🔍 Prometheus:"
    echo "  Command: kubectl port-forward service/prometheus-server 9090:80 -n monitoring"
    echo "  URL: http://localhost:9090"
    
    echo ""
    echo "🚀 Sample Application:"
    echo "  Command: kubectl port-forward service/sample-app-service 8080:80 -n devops-app"
    echo "  URL: http://localhost:8080"
    echo "  Health: http://localhost:8080/health"
    echo "  Metrics: http://localhost:8080/metrics"
    
    echo ""
    echo "🔧 Useful Commands:"
    echo "  Check all pods: kubectl get pods --all-namespaces"
    echo "  Check services: kubectl get services --all-namespaces"
    echo "  View app logs: kubectl logs -l app=sample-app -n devops-app"
    echo "  View monitoring logs: kubectl logs -l app.kubernetes.io/name=grafana -n monitoring"
    
    echo ""
    echo "🧹 Cleanup:"
    echo "  Run: ./scripts/cleanup.sh"
}

# Main execution
main() {
    echo "Starting workshop setup..."
    echo ""
    
    check_prerequisites
    setup_cluster
    deploy_application
    setup_monitoring
    wait_for_pods
    generate_traffic
    show_access_info
    
    echo ""
    print_success "🎉 Workshop environment is ready! Happy learning!"
}

# Handle script interruption
trap 'print_error "Setup interrupted. You may need to clean up manually."; exit 1' INT TERM

# Run main function
main "$@"
