#!/bin/bash
# Fix Log Analysis Dashboard Datasources

set -e

echo "🔧 Fixing Log Analysis Dashboard Datasource Configuration"
echo "========================================================"

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
GRAFANA_PASSWORD=$(kubectl get secret grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode)

# Check if port-forward is running
if ! curl -s http://localhost:3000 >/dev/null 2>&1; then
    print_warning "Grafana is not accessible on localhost:3000. Starting port-forward..."
    pkill -f "kubectl port-forward.*grafana" 2>/dev/null || true
    kubectl port-forward service/grafana 3000:80 -n monitoring >/dev/null 2>&1 &
    sleep 5
fi

# Get Loki datasource UID
print_status "Getting Loki datasource UID..."
loki_datasource_response=$(curl -s -X GET \
    -u "admin:${GRAFANA_PASSWORD}" \
    http://localhost:3000/api/datasources)

loki_uid=$(echo "$loki_datasource_response" | jq -r '.[] | select(.name=="Loki") | .uid')

if [ "$loki_uid" == "null" ] || [ -z "$loki_uid" ]; then
    print_error "Could not find Loki datasource. Please ensure Loki is properly configured."
    exit 1
fi

print_success "Found Loki datasource with UID: $loki_uid"

# Delete existing log analysis dashboard if it exists
print_status "Checking for existing Log Analysis dashboard..."
dashboards_response=$(curl -s -X GET \
    -u "admin:${GRAFANA_PASSWORD}" \
    http://localhost:3000/api/search?query=Log%20Analysis)

existing_dashboard_uid=$(echo "$dashboards_response" | jq -r '.[] | select(.title | contains("Log Analysis")) | .uid')

if [ "$existing_dashboard_uid" != "null" ] && [ -n "$existing_dashboard_uid" ]; then
    print_status "Deleting existing Log Analysis dashboard..."
    delete_response=$(curl -s -X DELETE \
        -u "admin:${GRAFANA_PASSWORD}" \
        "http://localhost:3000/api/dashboards/uid/$existing_dashboard_uid")
    print_success "Existing dashboard deleted"
fi

# Import the log analysis dashboard with correct datasource mapping
print_status "Importing Log Analysis dashboard with correct Loki datasource..."

dashboard_content=$(cat "dashboards/log-analysis.json")

# Create dashboard import payload with proper datasource mapping
dashboard_payload=$(jq -n \
    --argjson dashboard "$dashboard_content" \
    --arg loki_uid "$loki_uid" \
    '{
        dashboard: $dashboard,
        overwrite: true,
        inputs: [
            {
                name: "DS_LOKI",
                type: "datasource",
                pluginId: "loki",
                value: $loki_uid
            }
        ]
    }')

response=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -u "admin:${GRAFANA_PASSWORD}" \
    -d "$dashboard_payload" \
    http://localhost:3000/api/dashboards/import)

if echo "$response" | grep -q '"status":"success"' || echo "$response" | grep -q '"uid"'; then
    print_success "Log Analysis dashboard imported successfully with correct Loki datasource!"
    
    # Get the new dashboard UID
    new_dashboard_uid=$(echo "$response" | jq -r '.uid // .dashboard.uid')
    dashboard_url="http://localhost:3000/d/$new_dashboard_uid"
    
    echo ""
    print_success "✅ Dashboard Fix Complete!"
    echo ""
    echo "📊 Access your fixed Log Analysis dashboard:"
    echo "   URL: $dashboard_url"
    echo "   Username: admin"
    echo "   Password: $GRAFANA_PASSWORD"
    echo ""
    echo "🔍 All panels should now correctly use the Loki datasource for log queries."
    
else
    print_error "Failed to import dashboard: $response"
    
    # Try alternative approach - direct replacement in existing dashboard
    print_status "Trying alternative fix approach..."
    
    # Get all dashboards and find log analysis
    all_dashboards=$(curl -s -X GET \
        -u "admin:${GRAFANA_PASSWORD}" \
        http://localhost:3000/api/search?type=dash-db)
    
    log_dashboard_uid=$(echo "$all_dashboards" | jq -r '.[] | select(.title | test("Log|log")) | .uid')
    
    if [ "$log_dashboard_uid" != "null" ] && [ -n "$log_dashboard_uid" ]; then
        print_status "Found potential log dashboard with UID: $log_dashboard_uid"
        print_warning "Please manually check and update the datasource assignments in Grafana UI"
        echo "   Dashboard URL: http://localhost:3000/d/$log_dashboard_uid"
    fi
fi
