#!/bin/bash
# Monitoring Stack Validation Script
# This script validates all components and sets up port-forwards for easy access

set -e

echo "🔍 Monitoring Stack Validation & Setup Script"
echo "============================================="

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

# Check if we're in the right directory
if [ ! -f "main.tf" ]; then
    print_error "Please run this script from the 05-monitoring-stack directory"
    exit 1
fi

# Function to check if a port is already in use
check_port() {
    local port=$1
    if lsof -i :$port >/dev/null 2>&1; then
        return 0  # Port is in use
    else
        return 1  # Port is free
    fi
}

# Function to kill existing port-forwards
cleanup_port_forwards() {
    print_status "Cleaning up existing port-forwards..."
    pkill -f "kubectl port-forward" 2>/dev/null || true
    sleep 2
}

# Function to wait for pod to be ready
wait_for_pod() {
    local label=$1
    local namespace=$2
    local timeout=${3:-300}
    
    print_status "Waiting for pods with label $label in namespace $namespace..."
    if kubectl wait --for=condition=ready pod -l "$label" -n "$namespace" --timeout="${timeout}s" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to check if service exists and has endpoints
check_service() {
    local service=$1
    local namespace=$2
    
    if kubectl get service "$service" -n "$namespace" >/dev/null 2>&1; then
        local endpoints=$(kubectl get endpoints "$service" -n "$namespace" -o jsonpath='{.subsets[*].addresses[*].ip}' 2>/dev/null)
        if [ -n "$endpoints" ]; then
            return 0  # Service exists and has endpoints
        else
            return 1  # Service exists but no endpoints
        fi
    else
        return 1  # Service doesn't exist
    fi
}

# Function to test HTTP endpoint
test_endpoint() {
    local url=$1
    local name=$2
    local timeout=${3:-10}
    
    print_status "Testing $name endpoint: $url"
    if curl -s --max-time "$timeout" "$url" >/dev/null 2>&1; then
        print_success "$name is accessible"
        return 0
    else
        print_error "$name is not accessible"
        return 1
    fi
}

# Main validation function
validate_monitoring_stack() {
    print_status "Step 1: Checking namespace and basic resources..."
    
    # Check monitoring namespace
    if kubectl get namespace monitoring >/dev/null 2>&1; then
        print_success "Monitoring namespace exists"
    else
        print_error "Monitoring namespace not found"
        exit 1
    fi
    
    # Check Helm releases
    print_status "Checking Helm releases..."
    releases=$(helm list -n monitoring -q)
    expected_releases=("prometheus" "grafana" "loki" "alloy")
    
    for release in "${expected_releases[@]}"; do
        if echo "$releases" | grep -q "^$release$"; then
            status=$(helm status "$release" -n monitoring -o json | jq -r '.info.status')
            if [ "$status" = "deployed" ]; then
                print_success "Helm release '$release' is deployed"
            else
                print_warning "Helm release '$release' status: $status"
            fi
        else
            print_warning "Helm release '$release' not found"
        fi
    done
    
    print_status "Step 2: Checking pod status..."
    
    # Check all pods in monitoring namespace
    kubectl get pods -n monitoring --no-headers | while read -r line; do
        pod_name=$(echo "$line" | awk '{print $1}')
        status=$(echo "$line" | awk '{print $3}')
        ready=$(echo "$line" | awk '{print $2}')
        
        if [[ "$status" == "Running" && "$ready" == *"/"* ]]; then
            ready_count=$(echo "$ready" | cut -d'/' -f1)
            total_count=$(echo "$ready" | cut -d'/' -f2)
            if [ "$ready_count" = "$total_count" ]; then
                print_success "Pod $pod_name is ready ($ready)"
            else
                print_warning "Pod $pod_name is not ready ($ready)"
            fi
        else
            print_warning "Pod $pod_name status: $status ($ready)"
        fi
    done
    
    print_status "Step 3: Checking services and endpoints..."
    
    # Check critical services
    services=("prometheus-server:prometheus" "grafana:grafana" "loki:loki" "alloy:alloy")
    
    for service_info in "${services[@]}"; do
        service=$(echo "$service_info" | cut -d':' -f1)
        component=$(echo "$service_info" | cut -d':' -f2)
        
        if check_service "$service" "monitoring"; then
            print_success "Service '$service' has endpoints"
        else
            print_warning "Service '$service' has no endpoints or doesn't exist"
        fi
    done
    
    print_status "Step 4: Checking application is running..."
    
    # Check if sample app is running
    if kubectl get pods -n devops-app >/dev/null 2>&1; then
        app_pods=$(kubectl get pods -n devops-app --no-headers | grep -c "Running" || echo "0")
        if [ "$app_pods" -gt 0 ]; then
            print_success "Sample application is running ($app_pods pods)"
        else
            print_warning "Sample application pods are not running"
        fi
    else
        print_warning "Sample application namespace not found"
    fi
}

# Function to setup port forwards
setup_port_forwards() {
    print_status "Step 5: Setting up port-forwards..."
    
    # Clean up existing port-forwards
    cleanup_port_forwards
    
    # Array of port-forward configurations: "service:namespace:local_port:remote_port:name"
    port_forwards=(
        "grafana:monitoring:3000:80:Grafana"
        "prometheus-server:monitoring:9090:80:Prometheus"
        "loki:monitoring:3100:3100:Loki"
        "sample-app-service:devops-app:8080:80:Sample App"
    )
    
    # Start port-forwards in background
    for pf in "${port_forwards[@]}"; do
        IFS=':' read -r service namespace local_port remote_port name <<< "$pf"
        
        # Check if service exists
        if kubectl get service "$service" -n "$namespace" >/dev/null 2>&1; then
            # Check if port is already in use
            if check_port "$local_port"; then
                print_warning "Port $local_port is already in use, skipping $name"
                continue
            fi
            
            print_status "Setting up port-forward for $name (localhost:$local_port)"
            kubectl port-forward service/"$service" "$local_port:$remote_port" -n "$namespace" >/dev/null 2>&1 &
            
            # Give it a moment to start
            sleep 2
            
            # Verify port-forward is working
            if check_port "$local_port"; then
                print_success "$name port-forward is active on localhost:$local_port"
            else
                print_error "Failed to setup port-forward for $name"
            fi
        else
            print_warning "Service $service not found in namespace $namespace"
        fi
    done
    
    # Wait a bit for port-forwards to stabilize
    sleep 3
}

# Function to test all endpoints
test_endpoints() {
    print_status "Step 6: Testing all endpoints..."
    
    # Test endpoints - using | as separator to avoid issues with : in URLs
    endpoints=(
        "http://localhost:3000|Grafana UI"
        "http://localhost:9090|Prometheus UI"
        "http://localhost:9090/api/v1/query?query=up|Prometheus API"
        "http://localhost:3100/ready|Loki Ready"
        "http://localhost:8080/health|Sample App Health"
        "http://localhost:8080/metrics|Sample App Metrics"
    )
    
    for endpoint in "${endpoints[@]}"; do
        IFS='|' read -r url name <<< "$endpoint"
        test_endpoint "$url" "$name"
    done
}

# Function to get Grafana password
get_grafana_password() {
    print_status "Step 7: Getting Grafana credentials..."
    
    if kubectl get secret grafana -n monitoring >/dev/null 2>&1; then
        password=$(kubectl get secret grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode)
        print_success "Grafana credentials:"
        echo "  URL: http://localhost:3000"
        echo "  Username: admin"
        echo "  Password: $password"
    else
        print_warning "Grafana secret not found"
    fi
}

# Function to show quick access guide
show_access_guide() {
    echo ""
    echo "🎉 Monitoring Stack Validation Complete!"
    echo "======================================="
    echo ""
    echo "📊 Quick Access Guide:"
    echo "---------------------"
    echo "• Grafana Dashboard:    http://localhost:3000 (admin/admin123)"
    echo "• Prometheus UI:        http://localhost:9090"
    echo "• Loki API:             http://localhost:3100"
    echo "• Sample App:           http://localhost:8080"
    echo "• App Health:           http://localhost:8080/health"
    echo "• App Metrics:          http://localhost:8080/metrics"
    echo ""
    echo "🔍 Quick Tests:"
    echo "---------------"
    echo "• Check Prometheus targets: http://localhost:9090/targets"
    echo "• Query metrics: http://localhost:9090/graph"
    echo "• Check Grafana data sources: http://localhost:3000/datasources"
    echo "• Generate app traffic: for i in {1..10}; do curl http://localhost:8080/; done"
    echo ""
    echo "🚀 Next Steps:"
    echo "-------------"
    echo "• Explore Prometheus queries and targets"
    echo "• Import Kubernetes dashboards in Grafana (ID: 315)"
    echo "• Check application logs in Grafana Explore with Loki"
    echo "• Generate some application traffic and observe metrics"
    echo ""
    echo "⚠️  Note: Port-forwards are running in the background."
    echo "   To stop them: pkill -f 'kubectl port-forward'"
    echo ""
}

# Function to show monitoring tips
show_monitoring_tips() {
    echo "💡 Pro Tips:"
    echo "------------"
    echo "• Use 'kubectl get pods -n monitoring' to check pod status"
    echo "• Access Grafana Explore to query logs: http://localhost:3000/explore"
    echo "• Try these PromQL queries in Prometheus:"
    echo "  - up                              (service availability)"
    echo "  - rate(http_requests_total[5m])   (request rate)"
    echo "  - container_memory_usage_bytes    (memory usage)"
    echo "• Try these LogQL queries in Grafana:"
    echo "  - {namespace=\"devops-app\"}        (app logs)"
    echo "  - {namespace=\"devops-app\"} |= \"error\" (error logs)"
    echo ""
}

# Trap to cleanup on exit
trap 'echo ""; print_status "Cleaning up..."; cleanup_port_forwards' EXIT

# Main execution
main() {
    validate_monitoring_stack
    setup_port_forwards
    test_endpoints
    get_grafana_password
    show_access_guide
    show_monitoring_tips
    
    # Keep script running to maintain port-forwards
    print_status "Port-forwards are active. Press Ctrl+C to stop and cleanup."
    
    # Wait for interrupt
    while true; do
        sleep 10
        # Check if port-forwards are still active
        if ! pgrep -f "kubectl port-forward" >/dev/null; then
            print_warning "Port-forwards stopped. Exiting..."
            break
        fi
    done
}

# Run main function
main
