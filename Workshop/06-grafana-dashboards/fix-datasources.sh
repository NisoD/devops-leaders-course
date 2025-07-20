#!/bin/bash
# Fix Grafana Dashboard Datasource Assignments

set -e

echo "🔧 Fixing Grafana Dashboard Datasource Assignments"
echo "================================================="

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
if ! curl -s -f http://localhost:3000/api/health > /dev/null; then
    print_error "Grafana is not accessible on port 3000"
    print_status "Please ensure port-forward is running:"
    echo "kubectl port-forward service/grafana 3000:80 -n monitoring"
    exit 1
fi

# Get Grafana admin password
GRAFANA_PASSWORD=$(kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode 2>/dev/null || echo "admin")

print_status "Getting datasource information..."

# Get all datasources
datasources_response=$(curl -s -u "admin:${GRAFANA_PASSWORD}" http://localhost:3000/api/datasources)

# Get Loki datasource UID
loki_uid=$(echo "$datasources_response" | jq -r '.[] | select(.name=="Loki") | .uid')
prometheus_uid=$(echo "$datasources_response" | jq -r '.[] | select(.name=="Prometheus") | .uid')

if [ "$loki_uid" == "null" ] || [ -z "$loki_uid" ]; then
    print_error "Loki datasource not found!"
    echo "Available datasources:"
    echo "$datasources_response" | jq -r '.[] | "  - \(.name) (UID: \(.uid), Type: \(.type))"'
    exit 1
fi

print_success "Found Loki datasource with UID: $loki_uid"
print_success "Found Prometheus datasource with UID: $prometheus_uid"

# Get the Log Analysis dashboard
print_status "Finding Log Analysis dashboard..."

dashboards_response=$(curl -s -u "admin:${GRAFANA_PASSWORD}" http://localhost:3000/api/search?query=Log%20Analysis")
log_dashboard_uid=$(echo "$dashboards_response" | jq -r '.[] | select(.title | contains("Log Analysis")) | .uid')

if [ "$log_dashboard_uid" == "null" ] || [ -z "$log_dashboard_uid" ]; then
    print_warning "Log Analysis dashboard not found. Available dashboards:"
    curl -s -u "admin:${GRAFANA_PASSWORD}" http://localhost:3000/api/search | jq -r '.[] | "  - \(.title) (UID: \(.uid))"'
    exit 1
fi

print_success "Found Log Analysis dashboard with UID: $log_dashboard_uid"

# Get the dashboard JSON
print_status "Getting dashboard configuration..."
dashboard_response=$(curl -s -u "admin:${GRAFANA_PASSWORD}" "http://localhost:3000/api/dashboards/uid/$log_dashboard_uid")
dashboard_json=$(echo "$dashboard_response" | jq '.dashboard')

# Check if any panels are using the wrong datasource
print_status "Checking panel datasources..."
wrong_datasources=$(echo "$dashboard_json" | jq -r '.panels[] | select(.datasource.uid != "'$loki_uid'" and .datasource.type == "loki") | .id')

if [ -n "$wrong_datasources" ] && [ "$wrong_datasources" != "" ]; then
    print_warning "Found panels with incorrect datasource assignments"
    
    # Fix the datasources
    print_status "Fixing datasource assignments..."
    fixed_dashboard=$(echo "$dashboard_json" | jq --arg loki_uid "$loki_uid" '
        (.panels[] | select(.datasource.type == "loki") | .datasource.uid) = $loki_uid |
        (.panels[] | .targets[]? | select(.datasource.type == "loki") | .datasource.uid) = $loki_uid
    ')
    
    # Update the dashboard
    update_payload=$(jq -n --argjson dashboard "$fixed_dashboard" '{dashboard: $dashboard, overwrite: true}')
    
    update_response=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -u "admin:${GRAFANA_PASSWORD}" \
        -d "$update_payload" \
        http://localhost:3000/api/dashboards/db)
    
    if echo "$update_response" | grep -q '"status":"success"'; then
        print_success "Dashboard datasources fixed successfully!"
    else
        print_error "Failed to update dashboard: $update_response"
    fi
else
    print_success "All panels are using correct Loki datasource"
fi

# Verify the fix
print_status "Verifying dashboard configuration..."
verification_response=$(curl -s -u "admin:${GRAFANA_PASSWORD}" "http://localhost:3000/api/dashboards/uid/$log_dashboard_uid")
verification_json=$(echo "$verification_response" | jq '.dashboard')

loki_panels=$(echo "$verification_json" | jq -r '[.panels[] | select(.datasource.type == "loki")] | length')
correct_panels=$(echo "$verification_json" | jq -r --arg loki_uid "$loki_uid" '[.panels[] | select(.datasource.type == "loki" and .datasource.uid == $loki_uid)] | length')

print_success "Dashboard verification:"
echo "  • Total Loki panels: $loki_panels"
echo "  • Correctly configured: $correct_panels"

if [ "$loki_panels" -eq "$correct_panels" ]; then
    print_success "✅ All panels are correctly configured with Loki datasource!"
else
    print_warning "⚠️  Some panels may still have incorrect datasource assignments"
fi

echo ""
print_success "Fix complete! You can now access the dashboard at:"
echo "http://localhost:3000/d/$log_dashboard_uid/devops-workshop-log-analysis"
echo ""
print_status "If you still see issues:"
echo "1. Refresh the dashboard in your browser"
echo "2. Check the panel edit mode to verify datasource"
echo "3. Re-run this script if needed"
