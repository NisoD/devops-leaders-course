#!/bin/bash

# DevOps Workshop Cleanup Script
# This script cleans up all workshop resources

set -e

echo "🧹 DevOps Workshop Cleanup"
echo "=========================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Confirmation prompt
echo "This will destroy all workshop resources including:"
echo "- Kubernetes cluster"
echo "- Sample application"
echo "- Monitoring stack"
echo "- All data and configurations"
echo ""
read -p "Are you sure you want to proceed? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
print_status "Starting cleanup process..."

# Cleanup monitoring stack
if [ -d "05-monitoring-stack" ]; then
    echo ""
    print_status "Destroying monitoring stack..."
    cd 05-monitoring-stack
    if [ -f "terraform.tfstate" ]; then
        terraform destroy -auto-approve
        print_success "Monitoring stack destroyed"
    else
        print_warning "No monitoring stack state found"
    fi
    cd ..
fi

# Cleanup application
if [ -d "03-app-deployment" ]; then
    echo ""
    print_status "Destroying sample application..."
    cd 03-app-deployment
    if [ -f "terraform.tfstate" ]; then
        terraform destroy -auto-approve
        print_success "Sample application destroyed"
    else
        print_warning "No application state found"
    fi
    cd ..
fi
fi

# Cleanup Kubernetes cluster
if [ -d "02-terraform-k8s" ]; then
    echo ""
    print_status "Destroying Kubernetes cluster..."
    cd 02-terraform-k8s
    if [ -f "terraform.tfstate" ]; then
        terraform destroy -auto-approve
        print_success "Kubernetes cluster destroyed"
    else
        print_warning "No cluster state found"
    fi
    cd ..
fi

# Clean up any remaining Docker containers
echo ""
print_status "Cleaning up Docker containers..."
if docker ps -q --filter "label=io.x-k8s.kind.cluster" | grep -q .; then
    docker stop $(docker ps -q --filter "label=io.x-k8s.kind.cluster")
    docker rm $(docker ps -aq --filter "label=io.x-k8s.kind.cluster")
    print_success "Kind containers removed"
else
    print_status "No Kind containers found"
fi

# Clean up Kind networks
print_status "Cleaning up Docker networks..."
if docker network ls --filter "name=kind" -q | grep -q .; then
    docker network rm $(docker network ls --filter "name=kind" -q) 2>/dev/null || true
    print_success "Kind networks removed"
else
    print_status "No Kind networks found"
fi

# Clean up Terraform files (optional)
echo ""
read -p "Do you want to remove Terraform state files and plans? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Removing Terraform files..."
    find . -name "terraform.tfstate*" -delete
    find . -name "tfplan" -delete
    find . -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
    find . -name ".terraform.lock.hcl" -delete
    find . -name "kubeconfig" -delete
    print_success "Terraform files removed"
fi

# Clean up kubectl context
echo ""
print_status "Cleaning up kubectl contexts..."
kubectl config get-contexts -o name | grep "kind-" | xargs -r kubectl config delete-context
print_success "Kind contexts removed from kubectl"

echo ""
print_success "🎉 Workshop cleanup completed!"
echo ""
echo "All resources have been destroyed and cleaned up."
echo "You can now run the setup script again to restart the workshop."
