#!/bin/bash
# Grafana Dashboard and Datasource Validation Script

set -e

echo "🔍 Grafana Dashboard and Datasource Validation"
echo "=============================================="

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

# Check if Grafana is accessible
print_status "Checking Grafana accessibility..."

# Try to access Grafana
if curl -s -f http://localhost:3000/api/health > /dev/null; then
    print_success "Grafana is accessible on http://localhost:3000"
else
    print_error "Grafana is not accessible. Make sure port-forward is running:"
    echo "kubectl port-forward service/grafana 3000:80 -n monitoring"
    exit 1
fi

# Get Grafana admin password
GRAFANA_PASSWORD=$(kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode 2>/dev/null || echo "admin")

print_status "Checking datasources..."

# Check Prometheus datasource
prom_response=$(curl -s -u "admin:${GRAFANA_PASSWORD}" http://localhost:3000/api/datasources)
prom_check=$(echo "$prom_response" | jq -r '.[] | select(.name=="Prometheus") | .name')

if [ "$prom_check" == "Prometheus" ]; then
    print_success "Prometheus datasource found"
    
    # Test Prometheus connectivity
    prom_test=$(curl -s -u "admin:${GRAFANA_PASSWORD}" "http://localhost:3000/api/datasources/proxy/1/api/v1/query?query=up" 2>/dev/null || echo "error")
    if echo "$prom_test" | grep -q '"status":"success"'; then
        print_success "Prometheus datasource is working"
    else
        print_warning "Prometheus datasource found but not responding correctly"
    fi
else
    print_error "Prometheus datasource not found"
fi

# Check Loki datasource
loki_check=$(echo "$prom_response" | jq -r '.[] | select(.name=="Loki") | .name')
loki_uid=$(echo "$prom_response" | jq -r '.[] | select(.name=="Loki") | .uid')

if [ "$loki_check" == "Loki" ]; then
    print_success "Loki datasource found (UID: $loki_uid)"
    
    # Test Loki connectivity
    loki_test=$(curl -s -u "admin:${GRAFANA_PASSWORD}" "http://localhost:3000/api/datasources/proxy/$loki_uid/loki/api/v1/labels" 2>/dev/null || echo "error")
    if echo "$loki_test" | grep -q '"status":"success"'; then
        print_success "Loki datasource is working"
        
        # Check if we have logs
        logs_test=$(curl -s -u "admin:${GRAFANA_PASSWORD}" "http://localhost:3000/api/datasources/proxy/$loki_uid/loki/api/v1/query_range?query={app=\"devops-app\"}&start=$(date -d '1 hour ago' --iso-8601)&end=$(date --iso-8601)" 2>/dev/null || echo "error")
        if echo "$logs_test" | grep -q '"status":"success"'; then
            log_count=$(echo "$logs_test" | jq -r '.data.result | length')
            if [ "$log_count" -gt 0 ]; then
                print_success "Found logs from devops-app ($log_count streams)"
            else
                print_warning "Loki is working but no logs found for devops-app"
            fi
        else
            print_warning "Could not query logs from Loki"
        fi
    else
        print_warning "Loki datasource found but not responding correctly"
    fi
else
    print_error "Loki datasource not found"
fi

print_status "Checking dashboards..."

# Get list of dashboards
dashboards_response=$(curl -s -u "admin:${GRAFANA_PASSWORD}" http://localhost:3000/api/search)
dashboard_count=$(echo "$dashboards_response" | jq '. | length')

print_success "Found $dashboard_count dashboards"

# Check for specific dashboards
expected_dashboards=("DevOps Workshop - Log Analysis" "Application Overview" "Infrastructure Monitoring" "SRE Golden Signals")

for dashboard_name in "${expected_dashboards[@]}"; do
    dashboard_found=$(echo "$dashboards_response" | jq -r ".[] | select(.title==\"$dashboard_name\") | .title")
    if [ "$dashboard_found" == "$dashboard_name" ]; then
        print_success "Dashboard found: $dashboard_name"
    else
        print_warning "Dashboard missing: $dashboard_name"
    fi
done

echo ""
print_success "Validation complete!"
echo ""
echo "📊 Access Information:"
echo "  • Grafana: http://localhost:3000 (admin/$GRAFANA_PASSWORD)"
echo "  • Dashboards: $dashboard_count total found"
echo ""
echo "🔧 If there are issues:"
echo "  1. Ensure monitoring stack is deployed: cd ../03-monitoring && terraform apply"
echo "  2. Check port-forwards: kubectl port-forward service/grafana 3000:80 -n monitoring"
echo "  3. Re-import dashboards: ./deploy-enhanced-setup.sh"
echo "  4. Check logs: kubectl logs -n monitoring -l app.kubernetes.io/name=grafana"
