#!/bin/bash

# Workshop Status Check Script
# This script checks the status of all workshop components

set -e

echo "📊 DevOps Workshop Status Check"
echo "==============================="

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

echo ""
print_status "Checking workshop environment status..."

# Check prerequisites
echo ""
echo "📋 Prerequisites Check:"
echo "----------------------"

if command_exists docker && docker info >/dev/null 2>&1; then
    print_success "Docker is running"
else
    print_error "Docker is not running"
fi

if command_exists kubectl; then
    print_success "kubectl is installed"
else
    print_error "kubectl is not installed"
fi

if command_exists terraform; then
    print_success "Terraform is installed"
else
    print_error "Terraform is not installed"
fi

if command_exists helm; then
    print_success "Helm is installed"
else
    print_error "Helm is not installed"
fi

# Check Kubernetes cluster
echo ""
echo "🔧 Kubernetes Cluster:"
echo "----------------------"

if kubectl cluster-info --context kind-devops-workshop >/dev/null 2>&1; then
    print_success "Kind cluster is running"
    
    # Check nodes
    NODE_COUNT=$(kubectl get nodes --context kind-devops-workshop --no-headers | wc -l)
    READY_NODES=$(kubectl get nodes --context kind-devops-workshop --no-headers | grep " Ready " | wc -l)
    
    if [ "$NODE_COUNT" -eq "$READY_NODES" ]; then
        print_success "$READY_NODES/$NODE_COUNT nodes are ready"
    else
        print_warning "$READY_NODES/$NODE_COUNT nodes are ready"
    fi
    
    # Check system pods
    SYSTEM_PODS_TOTAL=$(kubectl get pods -n kube-system --context kind-devops-workshop --no-headers | wc -l)
    SYSTEM_PODS_RUNNING=$(kubectl get pods -n kube-system --context kind-devops-workshop --no-headers | grep "Running" | wc -l)
    
    if [ "$SYSTEM_PODS_TOTAL" -eq "$SYSTEM_PODS_RUNNING" ]; then
        print_success "$SYSTEM_PODS_RUNNING/$SYSTEM_PODS_TOTAL system pods are running"
    else
        print_warning "$SYSTEM_PODS_RUNNING/$SYSTEM_PODS_TOTAL system pods are running"
    fi
else
    print_error "Kind cluster is not running"
fi

# Check application
echo ""
echo "🚀 Sample Application:"
echo "---------------------"

if kubectl get namespace devops-app >/dev/null 2>&1; then
    print_success "Application namespace exists"
    
    # Check application pods
    APP_PODS_TOTAL=$(kubectl get pods -n devops-app --no-headers 2>/dev/null | wc -l)
    APP_PODS_RUNNING=$(kubectl get pods -n devops-app --no-headers 2>/dev/null | grep "Running" | wc -l)
    
    if [ "$APP_PODS_TOTAL" -gt 0 ]; then
        if [ "$APP_PODS_TOTAL" -eq "$APP_PODS_RUNNING" ]; then
            print_success "$APP_PODS_RUNNING/$APP_PODS_TOTAL application pods are running"
        else
            print_warning "$APP_PODS_RUNNING/$APP_PODS_TOTAL application pods are running"
        fi
        
        # Check application service
        if kubectl get service sample-app-service -n devops-app >/dev/null 2>&1; then
            print_success "Application service exists"
        else
            print_error "Application service not found"
        fi
        
        # Test application endpoint
        if curl -s http://localhost/health >/dev/null 2>&1; then
            print_success "Application is accessible at http://localhost"
        else
            print_warning "Application endpoint not accessible (try port-forward)"
        fi
    else
        print_error "No application pods found"
    fi
else
    print_error "Application namespace not found"
fi

# Check monitoring stack
echo ""
echo "📊 Monitoring Stack:"
echo "-------------------"

if kubectl get namespace monitoring >/dev/null 2>&1; then
    print_success "Monitoring namespace exists"
    
    # Check Prometheus
    if kubectl get deployment prometheus-server -n monitoring >/dev/null 2>&1; then
        PROM_REPLICAS=$(kubectl get deployment prometheus-server -n monitoring -o jsonpath='{.status.replicas}')
        PROM_READY=$(kubectl get deployment prometheus-server -n monitoring -o jsonpath='{.status.readyReplicas}')
        
        if [ "$PROM_REPLICAS" = "$PROM_READY" ]; then
            print_success "Prometheus is running ($PROM_READY/$PROM_REPLICAS replicas)"
        else
            print_warning "Prometheus is starting ($PROM_READY/$PROM_REPLICAS replicas ready)"
        fi
    else
        print_error "Prometheus not found"
    fi
    
    # Check Grafana
    if kubectl get deployment grafana -n monitoring >/dev/null 2>&1; then
        GRAFANA_REPLICAS=$(kubectl get deployment grafana -n monitoring -o jsonpath='{.status.replicas}')
        GRAFANA_READY=$(kubectl get deployment grafana -n monitoring -o jsonpath='{.status.readyReplicas}')
        
        if [ "$GRAFANA_REPLICAS" = "$GRAFANA_READY" ]; then
            print_success "Grafana is running ($GRAFANA_READY/$GRAFANA_REPLICAS replicas)"
            
            # Get Grafana password
            GRAFANA_PASSWORD=$(kubectl get secret grafana -o jsonpath="{.data.admin-password}" -n monitoring 2>/dev/null | base64 -d)
            if [ ! -z "$GRAFANA_PASSWORD" ]; then
                print_success "Grafana admin password available"
            fi
        else
            print_warning "Grafana is starting ($GRAFANA_READY/$GRAFANA_REPLICAS replicas ready)"
        fi
    else
        print_error "Grafana not found"
    fi
    
    # Check Loki
    if kubectl get statefulset loki -n monitoring >/dev/null 2>&1; then
        LOKI_REPLICAS=$(kubectl get statefulset loki -n monitoring -o jsonpath='{.status.replicas}')
        LOKI_READY=$(kubectl get statefulset loki -n monitoring -o jsonpath='{.status.readyReplicas}')
        
        if [ "$LOKI_REPLICAS" = "$LOKI_READY" ]; then
            print_success "Loki is running ($LOKI_READY/$LOKI_REPLICAS replicas)"
        else
            print_warning "Loki is starting ($LOKI_READY/$LOKI_REPLICAS replicas ready)"
        fi
    else
        print_error "Loki not found"
    fi
    
    # Check Alloy
    if kubectl get daemonset alloy -n monitoring >/dev/null 2>&1; then
        ALLOY_DESIRED=$(kubectl get daemonset alloy -n monitoring -o jsonpath='{.status.desiredNumberScheduled}')
        ALLOY_READY=$(kubectl get daemonset alloy -n monitoring -o jsonpath='{.status.numberReady}')
        
        if [ "$ALLOY_DESIRED" = "$ALLOY_READY" ]; then
            print_success "Alloy is running ($ALLOY_READY/$ALLOY_DESIRED pods)"
        else
            print_warning "Alloy is starting ($ALLOY_READY/$ALLOY_DESIRED pods ready)"
        fi
    else
        print_error "Alloy not found"
    fi
else
    print_error "Monitoring namespace not found"
fi

# Check storage
echo ""
echo "💾 Storage:"
echo "----------"

PV_COUNT=$(kubectl get pv --no-headers 2>/dev/null | wc -l)
PVC_COUNT=$(kubectl get pvc --all-namespaces --no-headers 2>/dev/null | wc -l)

if [ "$PV_COUNT" -gt 0 ]; then
    print_success "$PV_COUNT persistent volumes available"
else
    print_warning "No persistent volumes found"
fi

if [ "$PVC_COUNT" -gt 0 ]; then
    print_success "$PVC_COUNT persistent volume claims active"
else
    print_warning "No persistent volume claims found"
fi

# Provide access information
echo ""
echo "🌐 Access Information:"
echo "---------------------"

if kubectl get namespace monitoring >/dev/null 2>&1; then
    echo "To access Grafana:"
    echo "  kubectl port-forward service/grafana 3000:80 -n monitoring"
    echo "  URL: http://localhost:3000"
    echo "  Username: admin"
    if kubectl get secret grafana -n monitoring >/dev/null 2>&1; then
        GRAFANA_PASSWORD=$(kubectl get secret grafana -o jsonpath="{.data.admin-password}" -n monitoring | base64 -d)
        echo "  Password: $GRAFANA_PASSWORD"
    fi
    echo ""
    
    echo "To access Prometheus:"
    echo "  kubectl port-forward service/prometheus-server 9090:80 -n monitoring"
    echo "  URL: http://localhost:9090"
    echo ""
fi

if kubectl get namespace devops-app >/dev/null 2>&1; then
    echo "To access the sample application:"
    echo "  URL: http://localhost (if ingress is working)"
    echo "  Or: kubectl port-forward service/sample-app-service 8080:80 -n devops-app"
    echo ""
fi

echo "📝 Useful Commands:"
echo "------------------"
echo "# Check all pods across namespaces:"
echo "kubectl get pods --all-namespaces"
echo ""
echo "# View application logs:"
echo "kubectl logs -l app=sample-app -n devops-app -f"
echo ""
echo "# Check monitoring stack logs:"
echo "kubectl logs -l app.kubernetes.io/name=grafana -n monitoring"
echo "kubectl logs -l app.kubernetes.io/name=prometheus -n monitoring"
echo ""

echo "🎯 Workshop Status Complete!"
