#!/bin/bash
# Troubleshooting script for monitoring stack deployment issues

echo "🔍 Monitoring Stack Troubleshooting Script"
echo "=========================================="

# Check if we're in the right directory
if [ ! -f "main.tf" ]; then
    echo "❌ Please run this script from the 05-monitoring-stack directory"
    exit 1
fi

# Function to print colored output
print_status() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

print_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}

print_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

# Check namespace
print_status "Checking monitoring namespace..."
if kubectl get namespace monitoring &> /dev/null; then
    print_success "Monitoring namespace exists"
else
    print_error "Monitoring namespace not found"
fi

# Check Helm releases
print_status "Checking Helm releases..."
echo "Helm releases in monitoring namespace:"
helm list -n monitoring

# Check pods
print_status "Checking pod status..."
kubectl get pods -n monitoring

# Check for failed pods
failed_pods=$(kubectl get pods -n monitoring --field-selector=status.phase=Failed -o name 2>/dev/null)
if [ -n "$failed_pods" ]; then
    print_error "Found failed pods:"
    echo "$failed_pods"
    
    echo ""
    print_status "Checking failed pod logs..."
    for pod in $failed_pods; do
        echo "--- Logs for $pod ---"
        kubectl logs -n monitoring $pod --tail=50
        echo ""
    done
fi

# Check events
print_status "Recent events in monitoring namespace:"
kubectl get events -n monitoring --sort-by='.lastTimestamp' --field-selector=type=Warning | tail -10

# Check specific services
print_status "Checking service endpoints..."
kubectl get endpoints -n monitoring

# Check for common issues
print_status "Checking for common issues..."

# Check if Alloy is failing
if helm status alloy -n monitoring &> /dev/null; then
    alloy_status=$(helm status alloy -n monitoring -o json | jq -r '.info.status')
    if [ "$alloy_status" != "deployed" ]; then
        print_error "Alloy deployment failed with status: $alloy_status"
        echo "Consider running: helm uninstall alloy -n monitoring"
        echo "Then comment out Alloy in main.tf and run terraform apply"
    fi
fi

# Check PVC status
print_status "Checking persistent volume claims..."
kubectl get pvc -n monitoring

echo ""
echo "🔧 Common Solutions:"
echo "1. For failed Alloy: helm uninstall alloy -n monitoring && terraform apply"
echo "2. For failed Loki: terraform destroy -target=helm_release.loki && terraform apply"
echo "3. For timeout issues: Increase timeout in main.tf"
echo "4. For resource issues: Check cluster resources with kubectl top nodes"
echo ""
echo "📚 For more help, check the README troubleshooting section."
