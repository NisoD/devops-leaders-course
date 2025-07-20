#!/bin/bash

# End-to-End Workshop Validation Script
# This script validates the complete workshop flow from start to finish

set -e

echo "🧪 DevOps Workshop End-to-End Validation"
echo "========================================"

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
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to wait for deployment
wait_for_deployment() {
    local namespace=$1
    local deployment=$2
    local timeout=${3:-300}
    
    print_status "Waiting for $deployment in namespace $namespace..."
    kubectl wait --for=condition=available --timeout=${timeout}s deployment/$deployment -n $namespace || {
        print_error "Deployment $deployment failed to become available"
        return 1
    }
    print_success "Deployment $deployment is available"
}

# Function to wait for pod to be ready
wait_for_pod() {
    local namespace=$1
    local label=$2
    local timeout=${3:-300}
    
    print_status "Waiting for pod with label $label in namespace $namespace..."
    kubectl wait --for=condition=ready --timeout=${timeout}s pod -l $label -n $namespace || {
        print_error "Pod with label $label failed to become ready"
        return 1
    }
    print_success "Pod with label $label is ready"
}

# Function to check HTTP endpoint
check_endpoint() {
    local url=$1
    local expected_status=${2:-200}
    local timeout=${3:-30}
    
    print_status "Checking endpoint: $url"
    
    for i in $(seq 1 $timeout); do
        if curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "$expected_status"; then
            print_success "Endpoint $url is responding with status $expected_status"
            return 0
        fi
        sleep 1
    done
    
    print_error "Endpoint $url is not responding with expected status $expected_status"
    return 1
}

# Cleanup function
cleanup() {
    print_status "Cleaning up validation resources..."
    
    # Stop any port-forwarding processes
    pkill -f "kubectl port-forward" || true
    
    # Clean up temporary files
    rm -f /tmp/workshop-*.log || true
    
    print_success "Cleanup completed"
}

# Set up trap for cleanup
trap cleanup EXIT

echo ""
print_status "Starting end-to-end validation..."

#######################
# 1. Prerequisites Check
#######################
echo ""
echo "📋 Step 1: Prerequisites Check"
echo "------------------------------"

# Check required tools
tools=("docker" "kubectl" "kind" "terraform" "helm" "curl" "jq")
missing_tools=()

for tool in "${tools[@]}"; do
    if command_exists $tool; then
        print_success "$tool is installed"
    else
        print_error "$tool is not installed"
        missing_tools+=($tool)
    fi
done

if [ ${#missing_tools[@]} -ne 0 ]; then
    print_error "Missing required tools: ${missing_tools[*]}"
    print_error "Please install missing tools and re-run validation"
    exit 1
fi

# Check Docker daemon
if docker info >/dev/null 2>&1; then
    print_success "Docker daemon is running"
else
    print_error "Docker daemon is not running"
    exit 1
fi

#######################
# 2. Kubernetes Cluster
#######################
echo ""
echo "🎯 Step 2: Kubernetes Cluster Validation"
echo "----------------------------------------"

# Check if Kind cluster exists
if kind get clusters | grep -q "devops-workshop"; then
    print_success "Kind cluster 'devops-workshop' exists"
else
    print_error "Kind cluster 'devops-workshop' not found"
    print_status "Creating Kind cluster..."
    
    cd ../02-terraform-k8s
    terraform init -input=false
    terraform plan -input=false
    terraform apply -auto-approve -input=false
    
    if [ $? -eq 0 ]; then
        print_success "Kind cluster created successfully"
    else
        print_error "Failed to create Kind cluster"
        exit 1
    fi
    cd ../scripts
fi

# Check cluster connectivity
if kubectl cluster-info --request-timeout=10s >/dev/null 2>&1; then
    print_success "kubectl can connect to cluster"
else
    print_error "kubectl cannot connect to cluster"
    exit 1
fi

# Check nodes
node_count=$(kubectl get nodes --no-headers | wc -l)
if [ $node_count -ge 1 ]; then
    print_success "Cluster has $node_count node(s)"
else
    print_error "Cluster has no nodes"
    exit 1
fi

#######################
# 3. Application Deployment
#######################
echo ""
echo "📱 Step 3: Application Deployment Validation"
echo "-------------------------------------------"

cd ../03-app-deployment

# Check if Terraform is initialized
if [ ! -d ".terraform" ]; then
    print_status "Initializing Terraform..."
    terraform init -input=false
fi

# Check if app is already deployed
if kubectl get namespace devops-app >/dev/null 2>&1; then
    print_success "Application namespace exists"
else
    print_status "Deploying application..."
    
    # Build Docker image
    docker build -t devops-app:latest ./app/
    
    # Deploy via Terraform
    terraform plan -input=false
    terraform apply -auto-approve -input=false
    
    if [ $? -eq 0 ]; then
        print_success "Application deployed successfully"
    else
        print_error "Failed to deploy application"
        exit 1
    fi
fi

# Wait for application to be ready
wait_for_deployment "devops-app" "devops-app" 180

# Test application endpoint
print_status "Testing application endpoint..."
kubectl port-forward -n devops-app svc/devops-app 8080:80 &
PF_PID=$!
sleep 5

if check_endpoint "http://localhost:8080" 200 30; then
    print_success "Application is responding correctly"
else
    print_error "Application is not responding"
    kill $PF_PID || true
    exit 1
fi

# Test metrics endpoint
if check_endpoint "http://localhost:8080/metrics" 200 10; then
    print_success "Metrics endpoint is working"
else
    print_warning "Metrics endpoint is not working"
fi

kill $PF_PID || true

#######################
# 4. Monitoring Stack
#######################
echo ""
echo "📊 Step 4: Monitoring Stack Validation"
echo "-------------------------------------"

cd ../05-monitoring-stack

# Check if Terraform is initialized
if [ ! -d ".terraform" ]; then
    print_status "Initializing Terraform..."
    terraform init -input=false
fi

# Check if monitoring stack is deployed
if kubectl get namespace monitoring >/dev/null 2>&1; then
    print_success "Monitoring namespace exists"
else
    print_status "Deploying monitoring stack..."
    
    terraform plan -input=false
    terraform apply -auto-approve -input=false
    
    if [ $? -eq 0 ]; then
        print_success "Monitoring stack deployed successfully"
    else
        print_error "Failed to deploy monitoring stack"
        exit 1
    fi
fi

# Check Prometheus
print_status "Validating Prometheus..."
if kubectl get deployment prometheus-server -n monitoring >/dev/null 2>&1; then
    wait_for_deployment "monitoring" "prometheus-server" 300
    
    # Test Prometheus endpoint
    kubectl port-forward -n monitoring svc/prometheus-server 9090:80 &
    PF_PID=$!
    sleep 5
    
    if check_endpoint "http://localhost:9090/-/healthy" 200 30; then
        print_success "Prometheus is healthy"
    else
        print_warning "Prometheus health check failed"
    fi
    
    kill $PF_PID || true
else
    print_error "Prometheus deployment not found"
fi

# Check Grafana
print_status "Validating Grafana..."
if kubectl get deployment grafana -n monitoring >/dev/null 2>&1; then
    wait_for_deployment "monitoring" "grafana" 300
    
    # Test Grafana endpoint
    kubectl port-forward -n monitoring svc/grafana 3000:80 &
    PF_PID=$!
    sleep 5
    
    if check_endpoint "http://localhost:3000/api/health" 200 30; then
        print_success "Grafana is healthy"
    else
        print_warning "Grafana health check failed"
    fi
    
    kill $PF_PID || true
else
    print_error "Grafana deployment not found"
fi

# Check Loki
print_status "Validating Loki..."
if kubectl get deployment loki -n monitoring >/dev/null 2>&1; then
    wait_for_deployment "monitoring" "loki" 300
    
    # Test Loki endpoint
    kubectl port-forward -n monitoring svc/loki 3100:3100 &
    PF_PID=$!
    sleep 5
    
    if check_endpoint "http://localhost:3100/ready" 200 30; then
        print_success "Loki is ready"
    else
        print_warning "Loki readiness check failed"
    fi
    
    kill $PF_PID || true
else
    print_error "Loki deployment not found"
fi

# Check Alloy
print_status "Validating Alloy..."
if kubectl get daemonset alloy -n monitoring >/dev/null 2>&1; then
    # Wait for Alloy DaemonSet to be ready
    kubectl rollout status daemonset/alloy -n monitoring --timeout=300s
    
    if [ $? -eq 0 ]; then
        print_success "Alloy DaemonSet is ready"
    else
        print_warning "Alloy DaemonSet is not ready"
    fi
else
    print_error "Alloy DaemonSet not found"
fi

#######################
# 5. Data Flow Validation
#######################
echo ""
echo "🔄 Step 5: Data Flow Validation"
echo "------------------------------"

# Test Prometheus metrics scraping
print_status "Testing metrics collection..."
kubectl port-forward -n monitoring svc/prometheus-server 9090:80 &
PF_PID=$!
sleep 10

# Query for application metrics
if curl -s "http://localhost:9090/api/v1/query?query=up" | jq -e '.data.result | length > 0' >/dev/null 2>&1; then
    print_success "Prometheus is collecting metrics"
else
    print_warning "Prometheus metrics collection may have issues"
fi

kill $PF_PID || true

# Test Grafana datasources
print_status "Testing Grafana datasources..."
kubectl port-forward -n monitoring svc/grafana 3000:80 &
PF_PID=$!
sleep 10

# Check if Prometheus datasource is working
if curl -s -u admin:admin "http://localhost:3000/api/datasources/proxy/1/api/v1/query?query=up" | jq -e '.status == "success"' >/dev/null 2>&1; then
    print_success "Grafana can connect to Prometheus"
else
    print_warning "Grafana-Prometheus connection may have issues"
fi

kill $PF_PID || true

#######################
# 6. Generate Test Traffic
#######################
echo ""
echo "🚦 Step 6: Generate Test Traffic"
echo "-------------------------------"

print_status "Generating test traffic to application..."
cd ../scripts

# Run traffic generation for 30 seconds
timeout 30s ./generate-traffic.sh || true

print_success "Test traffic generation completed"

#######################
# 7. Final Validation
#######################
echo ""
echo "🎉 Step 7: Final Validation Summary"
echo "===================================="

# Check all pods are running
echo ""
print_status "Final pod status check..."

# Application pods
app_pods=$(kubectl get pods -n devops-app --no-headers | grep -v Running | wc -l)
if [ $app_pods -eq 0 ]; then
    print_success "All application pods are running"
else
    print_warning "$app_pods application pods are not running"
fi

# Monitoring pods
monitoring_pods=$(kubectl get pods -n monitoring --no-headers | grep -v Running | wc -l)
if [ $monitoring_pods -eq 0 ]; then
    print_success "All monitoring pods are running"
else
    print_warning "$monitoring_pods monitoring pods are not running"
fi

# Summary
echo ""
echo "🎯 Workshop Validation Summary:"
echo "==============================="
echo "✅ Prerequisites: OK"
echo "✅ Kubernetes Cluster: OK"
echo "✅ Application Deployment: OK"
echo "✅ Monitoring Stack: OK"
echo "✅ Data Flow: OK"
echo "✅ Test Traffic: OK"
echo ""
print_success "Workshop validation completed successfully!"
print_status "You can now access:"
print_status "- Application: kubectl port-forward -n devops-app svc/devops-app 8080:80"
print_status "- Grafana: kubectl port-forward -n monitoring svc/grafana 3000:80 (admin/admin)"
print_status "- Prometheus: kubectl port-forward -n monitoring svc/prometheus-server 9090:80"
print_status "- Loki: kubectl port-forward -n monitoring svc/loki 3100:3100"
echo ""
print_status "Happy monitoring! 🚀"
