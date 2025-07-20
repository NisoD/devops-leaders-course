#!/bin/bash
# Import Dashboards and Setup Grafana Script

set -e

echo "🚀 Importing Grafana Dashboards and Setting Up Monitoring"
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

# Check if we're in the right directory
if [ ! -f "README.md" ] || [ ! -d "dashboards" ]; then
    print_error "Please run this script from the 06-grafana-dashboards directory"
    exit 1
fi

print_status "Step 1: Verifying application is running..."

# Check if app is running
if kubectl get pods -n devops-app | grep -q "Running"; then
    print_success "Application is running and ready"
else
    print_error "Application is not running. Please ensure Task 2 (app deployment) was completed successfully."
    exit 1
fi

print_status "Step 2: Setting up port-forward to Grafana..."

# Kill any existing port-forwards
pkill -f "kubectl port-forward.*grafana" 2>/dev/null || true
sleep 2

# Start Grafana port-forward in background
kubectl port-forward service/grafana 3000:80 -n monitoring >/dev/null 2>&1 &
sleep 3

# Get Grafana password
GRAFANA_PASSWORD=$(kubectl get secret grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode)

print_status "Step 3: Configuring data sources and importing dashboards..."

# Wait for Grafana to be accessible
for i in {1..10}; do
    if curl -s http://localhost:3000 >/dev/null 2>&1; then
        print_success "Grafana is accessible"
        break
    else
        print_status "Waiting for Grafana to be ready... (attempt $i/10)"
        sleep 3
    fi
done

# Configure Prometheus data source
print_status "Configuring Prometheus data source..."
prometheus_payload='{
  "name": "Prometheus",
  "type": "prometheus",
  "url": "http://prometheus-server:80",
  "access": "proxy",
  "isDefault": true
}'

response=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -u "admin:${GRAFANA_PASSWORD}" \
    -d "$prometheus_payload" \
    http://localhost:3000/api/datasources)

if echo "$response" | grep -q '"message":"Datasource added"'; then
    print_success "Prometheus data source configured"
elif echo "$response" | grep -q '"message":"Data source with the same name already exists"'; then
    print_success "Prometheus data source already exists"
else
    print_warning "Prometheus data source configuration response: $response"
fi

# Configure Loki data source
print_status "Configuring Loki data source..."
loki_payload='{
  "name": "Loki",
  "type": "loki",
  "url": "http://loki:3100",
  "access": "proxy"
}'

response=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -u "admin:${GRAFANA_PASSWORD}" \
    -d "$loki_payload" \
    http://localhost:3000/api/datasources)

if echo "$response" | grep -q '"message":"Datasource added"'; then
    print_success "Loki data source configured"
elif echo "$response" | grep -q '"message":"Data source with the same name already exists"'; then
    print_success "Loki data source already exists"
else
    print_warning "Loki data source configuration response: $response"
fi

# Import each dashboard
print_status "Importing dashboards..."
dashboards=("application-overview" "infrastructure-monitoring" "log-analysis" "sre-golden-signals")

# First, get the Loki datasource UID
print_status "Getting Loki datasource UID..."
loki_datasource_response=$(curl -s -X GET \
    -u "admin:${GRAFANA_PASSWORD}" \
    http://localhost:3000/api/datasources)

loki_uid=$(echo "$loki_datasource_response" | jq -r '.[] | select(.name=="Loki") | .uid')

if [ "$loki_uid" == "null" ] || [ -z "$loki_uid" ]; then
    print_warning "Could not get Loki datasource UID, using default name mapping"
    loki_uid="loki"
fi

print_success "Loki datasource UID: $loki_uid"

for dashboard in "${dashboards[@]}"; do
    print_status "Importing $dashboard dashboard..."
    
    # Read the dashboard content
    dashboard_content=$(cat "dashboards/${dashboard}.json")
    
    # For log-analysis dashboard, handle the datasource template variable
    if [ "$dashboard" == "log-analysis" ]; then
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
    else
        # For other dashboards, use simple import
        dashboard_payload=$(jq -n \
            --argjson dashboard "$dashboard_content" \
            '{
                dashboard: $dashboard,
                overwrite: true
            }')
    fi
    
    response=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -u "admin:${GRAFANA_PASSWORD}" \
        -d "$dashboard_payload" \
        http://localhost:3000/api/dashboards/import)
    
    if echo "$response" | grep -q '"status":"success"'; then
        print_success "$dashboard dashboard imported successfully"
    elif echo "$response" | grep -q '"uid"'; then
        print_success "$dashboard dashboard imported successfully"
    else
        print_warning "Failed to import $dashboard dashboard: $response"
        
        # Fallback: try regular dashboard API
        print_status "Trying fallback import method for $dashboard..."
        fallback_response=$(curl -s -X POST \
            -H "Content-Type: application/json" \
            -u "admin:${GRAFANA_PASSWORD}" \
            -d "$(echo "$dashboard_content" | jq '. + {overwrite: true}')" \
            http://localhost:3000/api/dashboards/db)
        
        if echo "$fallback_response" | grep -q '"status":"success"'; then
            print_success "$dashboard dashboard imported successfully (fallback method)"
        else
            print_error "Failed to import $dashboard dashboard even with fallback"
        fi
    fi
done

print_status "Step 4: Generating some test traffic..."

# Port forward to app
kubectl port-forward service/sample-app-service 8080:80 -n devops-app >/dev/null 2>&1 &
sleep 3

# Generate traffic to create metrics and logs
print_status "Generating test traffic and logs..."
for i in {1..20}; do
    curl -s http://localhost:8080/ >/dev/null
    curl -s http://localhost:8080/health >/dev/null
    curl -s http://localhost:8080/users >/dev/null
    curl -s http://localhost:8080/orders >/dev/null
    curl -s http://localhost:8080/info >/dev/null
    
    # Occasionally hit error endpoint
    if [ $((i % 5)) -eq 0 ]; then
        curl -s http://localhost:8080/error >/dev/null 2>&1 || true
    fi
    
    sleep 0.5
done

print_success "Test traffic generated successfully"

echo ""
echo "🎉 Dashboard Setup Complete!"
echo "============================"
echo ""
echo "📊 Grafana Access:"
echo "  URL: http://localhost:3000"
echo "  Username: admin"
echo "  Password: $GRAFANA_PASSWORD"
echo ""
echo "📱 Available Dashboards:"
echo "  • Application Overview - Key app metrics and performance"
echo "  • Infrastructure Monitoring - Kubernetes cluster health"
echo "  • Log Analysis - Structured log analysis and correlation"
echo "  • SRE Golden Signals - Latency, Traffic, Errors, Saturation"
echo ""
echo "🔗 Direct Links:"
echo "  • Application: http://localhost:8080"
echo "  • Prometheus: http://localhost:9090 (run: kubectl port-forward service/prometheus-server 9090:80 -n monitoring)"
echo "  • Enhanced App Info: http://localhost:8080/info"
echo ""
echo "🚀 Next Steps:"
echo "  1. Explore the dashboards in Grafana"
echo "  2. Generate more traffic: curl http://localhost:8080/users"
echo "  3. Test error scenarios: curl http://localhost:8080/error"
echo "  4. Check correlation IDs in logs"
echo ""
echo "⚠️  Note: Port-forwards are running in background"
echo "   To stop: pkill -f 'kubectl port-forward'"
