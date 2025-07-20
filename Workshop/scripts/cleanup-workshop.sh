#!/bin/bash
# DevOps Workshop Cleanup Script
# This script cleans up all workshop resources and generated files
# Returns the workshop to a fresh, clean state ready for the next run

set -e

echo "🧹 DevOps Workshop Cleanup Script"
echo "=================================="

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

# Confirm cleanup
confirm_cleanup() {
    echo "⚠️  This will destroy all workshop resources including:"
    echo "   - Kubernetes cluster"
    echo "   - All applications and data"
    echo "   - Monitoring stack"
    echo "   - Docker images and containers"
    echo "   - Terraform state files and directories"
    echo "   - Generated kubeconfig files"
    echo "   - terraform.tfvars files"
    echo "   - IDE and editor temporary files"
    echo "   - All other generated workshop artifacts"
    echo ""
    echo "   This will return the workshop to a fresh, clean state."
    echo ""
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Cleanup cancelled."
        exit 0
    fi
}

# Stop any running port forwards
stop_port_forwards() {
    print_status "Stopping any running port forwards..."
    
    # Kill all kubectl port-forward processes
    pkill -f "kubectl port-forward" 2>/dev/null || true
    
    print_success "Port forwards stopped."
}

# Cleanup applications
cleanup_applications() {
    print_status "Cleaning up applications..."
    
    if [ -d "02-app-deployment" ]; then
        cd 02-app-deployment
        if [ -f "terraform.tfstate" ]; then
            terraform destroy -auto-approve 2>/dev/null || print_warning "App cleanup failed, continuing..."
        fi
        cd ..
    fi
    
    print_success "Applications cleaned up."
}

# Cleanup monitoring stack
cleanup_monitoring() {
    print_status "Cleaning up monitoring stack..."
    
    if [ -d "03-monitoring" ]; then
        cd 03-monitoring
        if [ -f "terraform.tfstate" ]; then
            terraform destroy -auto-approve 2>/dev/null || print_warning "Monitoring cleanup failed, continuing..."
        fi
        cd ..
    fi
    
    if [ -d "04-dashboards" ]; then
        cd 04-dashboards
        # Clean up any dashboard-related resources if needed
        cd ..
    fi
    
    print_success "Monitoring stack cleaned up."
}

# Cleanup Kubernetes cluster
cleanup_cluster() {
    print_status "Cleaning up Kubernetes cluster..."
    
    if [ -d "01-cluster-setup" ]; then
        cd 01-cluster-setup
        if [ -f "terraform.tfstate" ]; then
            terraform destroy -auto-approve 2>/dev/null || print_warning "Cluster cleanup failed, continuing..."
        fi
        cd ..
    fi
    
    print_success "Kubernetes cluster cleaned up."
}

# Manual cleanup for Kind clusters
manual_kind_cleanup() {
    print_status "Performing manual Kind cluster cleanup..."
    
    # Delete Kind clusters
    if command -v kind &> /dev/null; then
        kind delete cluster --name devops-workshop 2>/dev/null || true
        kind delete cluster --name kind 2>/dev/null || true
    fi
    
    print_success "Manual Kind cleanup completed."
}

# Cleanup Docker resources
cleanup_docker() {
    print_status "Cleaning up Docker resources..."
    
    # Remove workshop-related images specifically
    docker images | grep -E "(devops-sample-app|sample-app|enhanced-sample-app|kindest)" | awk '{print $3}' | xargs -r docker rmi -f 2>/dev/null || true
    
    # Clean up unused Docker resources
    docker system prune -f 2>/dev/null || true
    
    print_success "Docker resources cleaned up."
}

# Remove terraform files and generated content
cleanup_terraform_files() {
    print_status "Cleaning up Terraform files and generated content..."
    
    # Find and remove terraform files
    find . -name "terraform.tfstate*" -delete 2>/dev/null || true
    find . -name ".terraform*" -type d -exec rm -rf {} + 2>/dev/null || true
    find . -name "kubeconfig*" -delete 2>/dev/null || true
    find . -name "tfplan*" -delete 2>/dev/null || true
    find . -name ".terraform.lock.hcl" -delete 2>/dev/null || true
    
    # Remove terraform.tfvars files (but keep the .example files)
    find . -name "terraform.tfvars" -not -name "*.example" -delete 2>/dev/null || true
    
    # Remove any crash logs
    find . -name "crash.log" -delete 2>/dev/null || true
    find . -name "crash.*.log" -delete 2>/dev/null || true
    
    # Remove any temporary files
    find . -name "*.tmp" -delete 2>/dev/null || true
    find . -name "*.temp" -delete 2>/dev/null || true
    find . -name ".DS_Store" -delete 2>/dev/null || true
    
    # Remove any backup files
    find . -name "*.bak" -delete 2>/dev/null || true
    find . -name "*~" -delete 2>/dev/null || true
    
    # Remove any logs that might have been generated
    find . -name "*.log" -not -path "./Workshop/README.md" -delete 2>/dev/null || true
    
    print_success "Terraform files and generated content cleaned up."
}

# Cleanup kubectl contexts
cleanup_kubectl_contexts() {
    print_status "Cleaning up kubectl contexts..."
    
    # Remove Kind contexts
    kubectl config delete-context kind-devops-workshop 2>/dev/null || true
    kubectl config delete-cluster kind-devops-workshop 2>/dev/null || true
    kubectl config delete-user kind-devops-workshop 2>/dev/null || true
    
    # Clean up any other kind contexts
    kubectl config get-contexts -o name | grep "kind-" | xargs -r kubectl config delete-context 2>/dev/null || true
    
    print_success "kubectl contexts cleaned up."
}

# Remove IDE and editor files
cleanup_ide_files() {
    print_status "Cleaning up IDE and editor files..."
    
    # Remove VS Code settings (if accidentally committed)
    find . -name ".vscode" -type d -exec rm -rf {} + 2>/dev/null || true
    
    # Remove JetBrains IDE files
    find . -name ".idea" -type d -exec rm -rf {} + 2>/dev/null || true
    
    # Remove Vim swap files
    find . -name "*.swp" -delete 2>/dev/null || true
    find . -name "*.swo" -delete 2>/dev/null || true
    find . -name ".*.swp" -delete 2>/dev/null || true
    
    # Remove Emacs backup files
    find . -name "#*#" -delete 2>/dev/null || true
    find . -name ".#*" -delete 2>/dev/null || true
    
    print_success "IDE and editor files cleaned up."
}

# Remove workshop artifacts and generated content
cleanup_workshop_artifacts() {
    print_status "Cleaning up workshop artifacts and generated content..."
    
    # Remove any generated certificates or keys
    find . -name "*.pem" -delete 2>/dev/null || true
    find . -name "*.key" -delete 2>/dev/null || true
    find . -name "*.crt" -delete 2>/dev/null || true
    find . -name "*.cert" -delete 2>/dev/null || true
    
    # Remove any generated config files that shouldn't persist
    find . -name "config.yaml" -not -path "*/k8s-manifests/*" -delete 2>/dev/null || true
    find . -name "config.yml" -not -path "*/k8s-manifests/*" -delete 2>/dev/null || true
    
    # Remove any process ID files
    find . -name "*.pid" -delete 2>/dev/null || true
    
    # Remove any socket files
    find . -name "*.sock" -delete 2>/dev/null || true
    
    # Remove any database files that might have been created
    find . -name "*.db" -delete 2>/dev/null || true
    find . -name "*.sqlite" -delete 2>/dev/null || true
    
    print_success "Workshop artifacts cleaned up."
}

# Verify cleanup
verify_cleanup() {
    print_status "Verifying cleanup..."
    
    # Check for running containers
    RUNNING_CONTAINERS=$(docker ps -q --filter "label=io.x-k8s.kind.cluster=devops-workshop" 2>/dev/null | wc -l)
    if [ "$RUNNING_CONTAINERS" -gt 0 ]; then
        print_warning "Some containers may still be running. Run 'docker ps' to check."
    fi
    
    # Check for Kind clusters
    if command -v kind &> /dev/null; then
        KIND_CLUSTERS=$(kind get clusters 2>/dev/null | grep -c "devops-workshop" || echo "0")
        if [ "$KIND_CLUSTERS" -gt 0 ]; then
            print_warning "Some Kind clusters may still exist. Run 'kind get clusters' to check."
        fi
    fi
    
    print_success "Cleanup verification completed."
}

# Display final status
show_final_status() {
    print_success "🎉 Workshop cleanup completed!"
    echo ""
    echo "📋 What was cleaned up:"
    echo "  ✅ Kubernetes cluster (Kind)"
    echo "  ✅ Sample applications"
    echo "  ✅ Monitoring stack (Prometheus, Grafana, Loki)"
    echo "  ✅ Grafana dashboards"
    echo "  ✅ Docker images and containers"
    echo "  ✅ Terraform state files and directories"
    echo "  ✅ Generated kubeconfig files"
    echo "  ✅ terraform.tfvars files"
    echo "  ✅ IDE and editor temporary files"
    echo "  ✅ kubectl contexts"
    echo "  ✅ All workshop artifacts and generated files"
    echo ""
    echo "🔍 Manual verification commands:"
    echo "  Check containers: docker ps -a"
    echo "  Check images: docker images"
    echo "  Check Kind clusters: kind get clusters"
    echo "  Check kubectl contexts: kubectl config get-contexts"
    echo ""
    print_success "Thank you for participating in the DevOps Workshop! 🚀"
}

# Main execution
main() {
    confirm_cleanup
    
    echo ""
    print_status "Starting cleanup process..."
    
    stop_port_forwards
    cleanup_applications
    cleanup_monitoring
    cleanup_cluster
    manual_kind_cleanup
    cleanup_docker
    cleanup_terraform_files
    cleanup_kubectl_contexts
    cleanup_ide_files
    cleanup_workshop_artifacts
    verify_cleanup
    show_final_status
}

# Handle script interruption
trap 'print_error "Cleanup interrupted. Some resources may not be cleaned up."; exit 1' INT TERM

# Run main function
main "$@"
