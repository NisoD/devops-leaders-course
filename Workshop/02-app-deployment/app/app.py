from flask import Flask, jsonify, request, g
from prometheus_client import Counter, Histogram, generate_latest
import time
import logging
import sys
import json
import uuid
import traceback
from datetime import datetime
import os
import random

# Configure structured logging
logging.basicConfig(
    level=logging.INFO,
    format='%(message)s',
    stream=sys.stdout
)

app = Flask(__name__)

# Prometheus metrics
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint', 'status'])
REQUEST_DURATION = Histogram('http_request_duration_seconds', 'HTTP request duration')
ERROR_COUNT = Counter('http_errors_total', 'Total HTTP errors', ['error_type'])

# Sample data for demonstration
USERS = [
    {"id": 1, "name": "Alice", "email": "alice@example.com"},
    {"id": 2, "name": "Bob", "email": "bob@example.com"},
    {"id": 3, "name": "Charlie", "email": "charlie@example.com"}
]

ORDERS = [
    {"id": 101, "user_id": 1, "product": "Laptop", "amount": 999.99},
    {"id": 102, "user_id": 2, "product": "Mouse", "amount": 29.99},
    {"id": 103, "user_id": 1, "product": "Keyboard", "amount": 79.99}
]

def log_structured(level, message, **kwargs):
    """Log structured data in JSON format"""
    log_data = {
        "timestamp": datetime.utcnow().isoformat(),
        "level": level,
        "message": message,
        "service": "enhanced-sample-app",
        "version": "2.0.0",
        "environment": os.getenv("ENVIRONMENT", "workshop")
    }
    
    # Add correlation ID if available (only within request context)
    try:
        if hasattr(g, 'correlation_id'):
            log_data["correlation_id"] = g.correlation_id
    except RuntimeError:
        # Outside of application context, no correlation ID available
        pass
    
    # Add any additional fields
    log_data.update(kwargs)
    
    if level == "ERROR":
        logging.error(json.dumps(log_data))
    elif level == "WARN":
        logging.warning(json.dumps(log_data))
    else:
        logging.info(json.dumps(log_data))

@app.before_request
def before_request():
    # Generate or extract correlation ID
    correlation_id = request.headers.get('X-Correlation-ID', str(uuid.uuid4()))
    g.correlation_id = correlation_id
    g.start_time = time.time()
    
    # Log incoming request
    log_structured("INFO", "Request started", **{
        "request": {
            "method": request.method,
            "path": request.path,
            "remote_addr": request.remote_addr,
            "user_agent": request.headers.get("User-Agent", ""),
            "content_length": request.content_length,
            "args": dict(request.args)
        }
    })

@app.after_request
def after_request(response):
    duration = time.time() - g.start_time
    duration_ms = round(duration * 1000, 2)
    
    # Log request completion
    log_structured("INFO", "Request completed", **{
        "request": {
            "method": request.method,
            "path": request.path,
            "endpoint": request.endpoint or "unknown"
        },
        "response": {
            "status_code": response.status_code,
            "duration_ms": duration_ms,
            "content_length": response.content_length
        }
    })
    
    # Update Prometheus metrics
    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.endpoint or 'unknown',
        status=response.status_code
    ).inc()
    
    REQUEST_DURATION.observe(duration)
    
    # Add correlation ID to response headers
    response.headers['X-Correlation-ID'] = g.correlation_id
    
    return response

@app.errorhandler(Exception)
def handle_exception(error):
    """Global error handler with structured logging"""
    ERROR_COUNT.labels(error_type=type(error).__name__).inc()
    
    log_structured("ERROR", "Unhandled exception", **{
        "error": {
            "type": type(error).__name__,
            "message": str(error),
            "traceback": traceback.format_exc()
        },
        "request": {
            "method": request.method,
            "path": request.path,
            "remote_addr": request.remote_addr
        }
    })
    
    return jsonify({
        "error": "Internal server error",
        "correlation_id": g.correlation_id,
        "timestamp": datetime.utcnow().isoformat()
    }), 500

@app.route('/')
def home():
    log_structured("INFO", "Home endpoint accessed")
    return jsonify({
        'message': 'Hello from Enhanced DevOps Workshop App!',
        'service': 'enhanced-sample-app',
        'version': '2.0.0',
        'correlation_id': g.correlation_id,
        'features': ['structured_logging', 'metrics', 'tracing']
    })

@app.route('/health')
def health():
    # Simulate occasional health check issues
    if random.random() < 0.02:  # 2% chance of failure
        log_structured("WARN", "Health check showing degraded status")
        return jsonify({'status': 'degraded', 'correlation_id': g.correlation_id}), 503
    
    return jsonify({
        'status': 'healthy',
        'correlation_id': g.correlation_id,
        'timestamp': datetime.utcnow().isoformat()
    }), 200

@app.route('/ready')
def ready():
    log_structured("INFO", "Readiness check performed")
    return jsonify({
        'status': 'ready',
        'correlation_id': g.correlation_id
    }), 200

@app.route('/users')
def get_users():
    log_structured("INFO", "Users endpoint accessed", extra={"user_count": len(USERS)})
    
    # Simulate slow database query occasionally
    if random.random() < 0.1:  # 10% chance
        delay = random.uniform(0.5, 2.0)
        log_structured("WARN", "Slow database query detected", extra={"delay_seconds": delay})
        time.sleep(delay)
    
    return jsonify({
        'users': USERS,
        'count': len(USERS),
        'correlation_id': g.correlation_id
    })

@app.route('/users/<int:user_id>')
def get_user(user_id):
    log_structured("INFO", "Individual user requested", extra={"user_id": user_id})
    
    user = next((u for u in USERS if u['id'] == user_id), None)
    if not user:
        log_structured("WARN", "User not found", extra={"user_id": user_id})
        return jsonify({
            'error': 'User not found',
            'correlation_id': g.correlation_id
        }), 404
    
    return jsonify({
        'user': user,
        'correlation_id': g.correlation_id
    })

@app.route('/orders')
def get_orders():
    user_id = request.args.get('user_id', type=int)
    
    if user_id:
        orders = [o for o in ORDERS if o['user_id'] == user_id]
        log_structured("INFO", "Orders filtered by user", extra={
            "user_id": user_id,
            "order_count": len(orders)
        })
    else:
        orders = ORDERS
        log_structured("INFO", "All orders requested", extra={"order_count": len(orders)})
    
    return jsonify({
        'orders': orders,
        'count': len(orders),
        'correlation_id': g.correlation_id
    })

@app.route('/orders', methods=['POST'])
def create_order():
    try:
        order_data = request.get_json()
        if not order_data:
            log_structured("WARN", "Invalid order data - no JSON provided")
            return jsonify({
                'error': 'Invalid JSON data',
                'correlation_id': g.correlation_id
            }), 400
        
        # Validate required fields
        required_fields = ['user_id', 'product', 'amount']
        missing_fields = [field for field in required_fields if field not in order_data]
        
        if missing_fields:
            log_structured("WARN", "Invalid order data - missing fields", extra={
                "missing_fields": missing_fields,
                "provided_data": order_data
            })
            return jsonify({
                'error': f'Missing required fields: {missing_fields}',
                'correlation_id': g.correlation_id
            }), 400
        
        # Create new order
        new_order = {
            'id': max([o['id'] for o in ORDERS]) + 1,
            'user_id': order_data['user_id'],
            'product': order_data['product'],
            'amount': order_data['amount']
        }
        
        ORDERS.append(new_order)
        
        log_structured("INFO", "Order created successfully", extra={
            "order_id": new_order['id'],
            "user_id": new_order['user_id'],
            "product": new_order['product'],
            "amount": new_order['amount']
        })
        
        return jsonify({
            'order': new_order,
            'correlation_id': g.correlation_id
        }), 201
        
    except Exception as e:
        log_structured("ERROR", "Failed to create order", **{
            "error": {
                "type": type(e).__name__,
                "message": str(e)
            }
        })
        raise

@app.route('/error')
def trigger_error():
    """Endpoint to trigger errors for testing"""
    log_structured("WARN", "Error endpoint called - triggering test error")
    raise Exception("This is a test error for demonstration purposes")

@app.route('/timeout')
def trigger_timeout():
    """Endpoint to simulate slow responses"""
    delay = random.uniform(2, 5)
    log_structured("WARN", "Timeout endpoint called", extra={"delay_seconds": delay})
    time.sleep(delay)
    return jsonify({
        'message': 'This response was intentionally slow',
        'delay_seconds': delay,
        'correlation_id': g.correlation_id
    })

@app.route('/metrics')
def metrics():
    """Prometheus metrics endpoint"""
    return generate_latest()

@app.route('/info')
def info():
    """Application information endpoint"""
    log_structured("INFO", "Info endpoint accessed")
    return jsonify({
        'app': 'enhanced-sample-app',
        'version': '2.0.0',
        'environment': os.getenv('ENVIRONMENT', 'workshop'),
        'features': [
            'structured_logging',
            'prometheus_metrics',
            'correlation_ids',
            'error_handling',
            'health_checks'
        ],
        'endpoints': {
            'health': '/health',
            'ready': '/ready',
            'metrics': '/metrics',
            'users': '/users',
            'orders': '/orders',
            'info': '/info',
            'test_error': '/error',
            'test_timeout': '/timeout'
        },
        'correlation_id': g.correlation_id,
        'timestamp': datetime.utcnow().isoformat()
    })

if __name__ == '__main__':
    log_structured("INFO", "Application starting", extra={
        "port": 5000,
        "debug": False
    })
    app.run(host='0.0.0.0', port=5000, debug=False)
