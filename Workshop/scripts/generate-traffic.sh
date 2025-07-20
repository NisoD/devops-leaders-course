#!/bin/bash
# Generate sample traffic for testing the workshop environment

set -e

echo "🚀 Generating Sample Traffic for DevOps Workshop"
echo "==============================================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Configuration
APP_URL="http://localhost"
DURATION=${1:-60}  # Default 60 seconds
CONCURRENT_USERS=${2:-5}  # Default 5 concurrent users

# Endpoints to test
ENDPOINTS=(
    "/"
    "/health"
    "/info"
    "/users"
    "/users/1"
    "/users/2"
    "/orders"
    "/orders?user_id=1"
)

# Generate traffic for a single user
generate_user_traffic() {
    local user_id=$1
    local end_time=$((SECONDS + DURATION))
    
    print_status "User $user_id: Starting traffic generation for ${DURATION}s"
    
    while [ $SECONDS -lt $end_time ]; do
        # Select random endpoint
        endpoint=${ENDPOINTS[$RANDOM % ${#ENDPOINTS[@]}]}
        
        # Make request with correlation ID
        correlation_id="user-${user_id}-$(date +%s%N)"
        
        curl -s \
            -H "X-Correlation-ID: $correlation_id" \
            -H "User-Agent: Workshop-Load-Test-User-$user_id" \
            "$APP_URL$endpoint" > /dev/null
        
        # Random delay between requests (0.1 to 2 seconds)
        delay=$(awk "BEGIN {print (rand() * 1.9) + 0.1}")
        sleep $delay
        
        # Occasionally trigger errors (5% chance)
        if [ $((RANDOM % 20)) -eq 0 ]; then
            curl -s "$APP_URL/error" > /dev/null 2>&1 || true
        fi
        
        # Occasionally trigger slow requests (10% chance)
        if [ $((RANDOM % 10)) -eq 0 ]; then
            curl -s "$APP_URL/timeout" > /dev/null 2>&1 || true
        fi
    done
    
    print_success "User $user_id: Traffic generation completed"
}

# POST request simulation
generate_post_traffic() {
    local end_time=$((SECONDS + DURATION))
    
    print_status "Starting POST request simulation"
    
    while [ $SECONDS -lt $end_time ]; do
        # Create order with random data
        user_id=$((RANDOM % 3 + 1))
        products=("Laptop" "Mouse" "Keyboard" "Monitor" "Headphones" "Webcam")
        product=${products[$RANDOM % ${#products[@]}]}
        amount=$(awk "BEGIN {print int(rand() * 1000) + 10}")
        
        curl -s \
            -X POST \
            -H "Content-Type: application/json" \
            -H "X-Correlation-ID: post-$(date +%s%N)" \
            -d "{\"user_id\": $user_id, \"product\": \"$product\", \"amount\": $amount}" \
            "$APP_URL/orders" > /dev/null
        
        # Less frequent POST requests
        sleep 5
    done
    
    print_success "POST request simulation completed"
}

# Check if application is accessible
check_app_accessibility() {
    print_status "Checking application accessibility..."
    
    if ! curl -s "$APP_URL/health" > /dev/null; then
        echo "❌ Application is not accessible at $APP_URL"
        echo "Please ensure the application is running and accessible."
        echo ""
        echo "To start port forwarding:"
        echo "kubectl port-forward service/sample-app-service 80:80 -n devops-app"
        exit 1
    fi
    
    print_success "Application is accessible at $APP_URL"
}

# Main traffic generation
main() {
    echo "Configuration:"
    echo "  Target URL: $APP_URL"
    echo "  Duration: ${DURATION}s"
    echo "  Concurrent Users: $CONCURRENT_USERS"
    echo ""
    
    check_app_accessibility
    
    print_status "Starting traffic generation with $CONCURRENT_USERS concurrent users..."
    
    # Start background traffic generators
    pids=()
    
    # Start user traffic generators
    for i in $(seq 1 $CONCURRENT_USERS); do
        generate_user_traffic $i &
        pids+=($!)
    done
    
    # Start POST traffic generator
    generate_post_traffic &
    pids+=($!)
    
    # Wait for all background processes
    for pid in "${pids[@]}"; do
        wait $pid
    done
    
    print_success "All traffic generation completed!"
    echo ""
    echo "📊 Check your monitoring dashboards to see the generated metrics:"
    echo "  - Grafana: kubectl port-forward service/grafana 3000:80 -n monitoring"
    echo "  - Prometheus: kubectl port-forward service/prometheus-server 9090:80 -n monitoring"
}

# Usage information
usage() {
    echo "Usage: $0 [DURATION_SECONDS] [CONCURRENT_USERS]"
    echo ""
    echo "Examples:"
    echo "  $0                    # 60 seconds, 5 users"
    echo "  $0 120               # 120 seconds, 5 users"
    echo "  $0 300 10            # 300 seconds, 10 users"
    echo ""
    echo "Note: Make sure the application is accessible at $APP_URL"
    exit 0
}

# Check for help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

# Run main function
main "$@"
