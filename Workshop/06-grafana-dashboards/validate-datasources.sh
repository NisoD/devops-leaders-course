#!/bin/bash
# Dashboard Validation Script - Check datasource mappings

set -e

echo "🔍 Grafana Dashboard Datasource Validation"
echo "=========================================="

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

# Get Grafana password
print_status "Getting Grafana admin password..."
GRAFANA_PASSWORD=$(kubectl get secret grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode)

# Check if port-forward is running
if ! curl -s http://localhost:3000 >/dev/null 2>&1; then
    print_warning "Grafana is not accessible on localhost:3000. Starting port-forward..."
    pkill -f "kubectl port-forward.*grafana" 2>/dev/null || true
    kubectl port-forward service/grafana 3000:80 -n monitoring >/dev/null 2>&1 &
    sleep 5
fi

# Check datasources
print_status "Checking available datasources..."
datasources_response=$(curl -s -X GET \
    -u "admin:${GRAFANA_PASSWORD}" \
    http://localhost:3000/api/datasources)

echo "Available datasources:"
echo "$datasources_response" | jq -r '.[] | "  - \(.name) (\(.type)): UID = \(.uid)"'

prometheus_uid=$(echo "$datasources_response" | jq -r '.[] | select(.name=="Prometheus") | .uid')
loki_uid=$(echo "$datasources_response" | jq -r '.[] | select(.name=="Loki") | .uid')

if [ "$prometheus_uid" != "null" ] && [ -n "$prometheus_uid" ]; then
    print_success "Prometheus datasource found with UID: $prometheus_uid"
else
    print_error "Prometheus datasource not found!"
fi

if [ "$loki_uid" != "null" ] && [ -n "$loki_uid" ]; then
    print_success "Loki datasource found with UID: $loki_uid"
else
    print_error "Loki datasource not found!"
fi

# Test datasource connectivity
print_status "Testing datasource connectivity..."

# Test Prometheus
prometheus_test=$(curl -s -X GET \
    -u "admin:${GRAFANA_PASSWORD}" \
    "http://localhost:3000/api/datasources/uid/$prometheus_uid/health")

if echo "$prometheus_test" | grep -q '"status":"ok"'; then
    print_success "Prometheus datasource connectivity: OK"
else
    print_warning "Prometheus datasource connectivity: FAILED - $prometheus_test"
fi

# Test Loki
loki_test=$(curl -s -X GET \
    -u "admin:${GRAFANA_PASSWORD}" \
    "http://localhost:3000/api/datasources/uid/$loki_uid/health")

if echo "$loki_test" | grep -q '"status":"ok"'; then
    print_success "Loki datasource connectivity: OK"
else
    print_warning "Loki datasource connectivity: FAILED - $loki_test"
fi

# Check dashboards
print_status "Checking imported dashboards..."
dashboards_response=$(curl -s -X GET \
    -u "admin:${GRAFANA_PASSWORD}" \
    http://localhost:3000/api/search?type=dash-db)

echo "Available dashboards:"
echo "$dashboards_response" | jq -r '.[] | "  - \(.title) (UID: \(.uid))"'

# Check log analysis dashboard specifically
log_dashboard=$(echo "$dashboards_response" | jq -r '.[] | select(.title | contains("Log Analysis")) | .uid')

if [ "$log_dashboard" != "null" ] && [ -n "$log_dashboard" ]; then
    print_success "Log Analysis dashboard found with UID: $log_dashboard"
    
    # Get dashboard details
    print_status "Checking Log Analysis dashboard datasource configuration..."
    dashboard_details=$(curl -s -X GET \
        -u "admin:${GRAFANA_PASSWORD}" \
        "http://localhost:3000/api/dashboards/uid/$log_dashboard")
    
    # Check if any panel uses prometheus instead of loki
    prometheus_panels=$(echo "$dashboard_details" | jq -r '.dashboard.panels[]? | select(.datasource.type == "prometheus") | .title')
    loki_panels=$(echo "$dashboard_details" | jq -r '.dashboard.panels[]? | select(.datasource.type == "loki") | .title')
    
    if [ -n "$prometheus_panels" ]; then
        print_error "Found panels using Prometheus datasource in Log Analysis dashboard:"
        echo "$prometheus_panels" | while read panel; do
            echo "  - $panel"
        done
    fi
    
    if [ -n "$loki_panels" ]; then
        print_success "Found panels correctly using Loki datasource:"
        echo "$loki_panels" | while read panel; do
            echo "  - $panel"
        done
    fi
else
    print_error "Log Analysis dashboard not found!"
fi

echo ""
echo "🎯 Validation Summary"
echo "===================="
echo "✅ Prometheus datasource: $([ "$prometheus_uid" != "null" ] && echo "OK" || echo "FAILED")"
echo "✅ Loki datasource: $([ "$loki_uid" != "null" ] && echo "OK" || echo "FAILED")"
echo "✅ Log Analysis dashboard: $([ "$log_dashboard" != "null" ] && echo "FOUND" || echo "MISSING")"
echo ""
echo "📊 Access Information:"
echo "  • Grafana: http://localhost:3000"
echo "  • Username: admin"
echo "  • Password: $GRAFANA_PASSWORD"
echo ""

if [ -n "$prometheus_panels" ]; then
    echo "❌ ACTION REQUIRED: Some log panels are using Prometheus instead of Loki!"
    echo "   Please re-run the dashboard import or manually fix the datasource assignments."
else
    echo "✅ All datasource assignments appear correct!"
fi
