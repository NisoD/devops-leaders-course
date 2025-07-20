# Task 2: Deploy Application via Terraform

## 🎯 Objective

Learn how to deploy applications to Kubernetes using Terraform. We'll deploy a sample web application with structured logging and observability features.

```bash
# Check if pods are running
kubectl get pods -n devops-app

# Check services
kubectl get services -n devops-app

# Check ingress
kubectl get ingress -n devops-app

# Set up port forwarding to access the application (recommended approach)
kubectl port-forward service/sample-app-service 8080:80 -n devops-app

# In a new terminal, test the application
curl http://localhost:8080/health
```Kubernetes resources including deployments, services, and ingress.

## ⏱️ Time: 5 minutes

## 📚 What You'll Learn

- Building Docker images for Kubernetes deployment
- Loading images into Kind clusters
- Managing Kubernetes resources with Terraform
- Deploying applications declaratively
- Working with Kubernetes manifests in Terraform
- Setting up ingress and services
- Understanding application observability preparation

## 🛠️ Prerequisites

- Completed Task 1 (Kubernetes cluster running via Kind)
- Basic understanding of Kubernetes concepts
- kubectl configured with cluster context
- Docker installed and running

**Verification:**
```bash
# Check if cluster is running
kubectl cluster-info

# Verify Docker is working
docker version
```

## 📁 Files Overview

```
03-app-deployment/
├── README.md              # This file
├── main.tf               # Main Terraform configuration
├── variables.tf          # Input variables
├── outputs.tf            # Output values
├── versions.tf           # Provider requirements
├── terraform.tfvars.example  # Example variables
├── app/                  # Sample application
│   ├── Dockerfile
│   ├── app.py
│   └── requirements.txt
└── manifests/            # Kubernetes manifests
    ├── namespace.yaml
    ├── deployment.yaml
    ├── service.yaml
    └── ingress.yaml
```

## 🚀 Step-by-Step Guide

### Step 1: Understand the Application

We'll deploy a simple Python Flask application that:
- Serves HTTP requests
- Provides health check endpoints
- Includes structured logging (for observability)
- Exposes metrics endpoint (for Prometheus)

Let's first examine the application code:

```bash
# Navigate to the app deployment directory
cd 03-app-deployment

# Look at the application structure
ls -la app/

# Review the application code
cat app/app.py
cat app/requirements.txt
cat app/Dockerfile
```

### Step 2: Build the Docker Image

Before we can deploy the application, we need to build the Docker image:

```bash
# Build the Docker image
cd app/
docker build -t devops-sample-app:latest .

# Verify the image was built
docker images | grep devops-sample-app

# Go back to the terraform directory
cd ..
```

### Step 3: Load Image into Kind Cluster (Optional - Automated by Terraform)

Since we're using Kind (Kubernetes in Docker), we need to load our locally built image into the cluster. **Note: Terraform will do this automatically, but you can also do it manually:**

```bash
# Load the image into the Kind cluster (optional - Terraform does this)
kind load docker-image devops-sample-app:latest --name devops-workshop

# Verify the image is available in the cluster
docker exec -it devops-workshop-control-plane crictl images | grep devops-sample-app
```

**💡 Note:** Our Terraform configuration automatically handles image loading and detects when images change to trigger rolling deployments!

### Step 4: Review Terraform Configuration

Now let's understand how Terraform will deploy our application:

```bash
# Review the configuration files
cat main.tf
cat variables.tf
```

**Key points to notice:**
- The `null_resource` that handles image loading automatically
- The `image_pull_policy = "Never"` setting to use our local image
- The dependency chain ensuring proper deployment order

### Step 5: Initialize and Plan

```bash
# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan
```

### Step 6: Deploy the Application

```bash
# Apply the configuration
terraform apply
```

**Note:** Terraform will automatically load the Docker image into Kind as part of the deployment process, but since we already loaded it manually, this step will be quick.

### Step 6.1: Updating the Application (Automatic Rolling Deployments)

Our Terraform configuration is designed to detect image changes and automatically trigger rolling deployments. Here's how it works:

```bash
# Make changes to your application code
vim app/app.py

# Rebuild the Docker image (same tag)
cd app/
docker build -t devops-sample-app:latest .
cd ..

# Apply Terraform - it will detect the image change and roll out the new version
terraform apply

# Watch the rolling deployment
kubectl rollout status deployment/sample-app -n devops-app
```

**How it works:**
- Terraform detects the Docker image hash has changed
- Automatically loads the new image into Kind
- Updates the deployment's pod template with the new image hash annotation
- Kubernetes performs a rolling deployment with zero downtime

**💡 Pro Tip:** This eliminates the manual step of loading images into Kind and ensures your deployments stay in sync with your code changes!

### Step 7: (Optional) Set up Ingress Controller

For ingress to work, we need an ingress controller. This is optional for this workshop since we'll use port-forwarding:

```bash
# Install nginx ingress controller for Kind
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for ingress controller to be ready
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s
```

### Step 8: Verify the Deployment

```bash
# Check if pods are running
kubectl get pods -n devops-app

# Check services
kubectl get services -n devops-app

# Check ingress
kubectl get ingress -n devops-app

# Set up port forwarding to access the application (recommended approach)
kubectl port-forward service/sample-app-service 8080:80 -n devops-app

# In a new terminal, test the application
curl http://localhost:8080/health
```

**💡 Why Port-Forward?**
- Works immediately without ingress controller setup
- Direct access to the service
- Perfect for development and testing
- More reliable than ingress in local environments

## 🔍 Understanding the Deployment

### Docker Image Build Process

Our application uses a multi-stage Docker build:

```dockerfile
# Base Python image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .

# Expose port
EXPOSE 5000

# Run the application
CMD ["python", "app.py"]
```

**Key benefits:**
- Lightweight final image
- Cached dependency layers
- Security best practices

### Kind Image Loading

Kind clusters run in Docker containers, so we need to explicitly load our images:

```bash
# This command copies the image from Docker to Kind
kind load docker-image devops-sample-app:latest --name devops-workshop
```

**Why this is needed:**
- Kind clusters are isolated from the host Docker daemon
- Images must be explicitly transferred
- Terraform automates this with `null_resource`

### Application Components

#### **1. Namespace**
Isolates our application resources:
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: devops-app
```

#### **2. Deployment**
Manages our application pods:
- 3 replicas for high availability
- Health checks (liveness and readiness probes)
- Resource limits and requests
- Environment variables for configuration

#### **3. Service**
Exposes the application within the cluster:
- ClusterIP service for internal communication
- Port 80 → 5000 mapping

#### **4. Ingress**
Exposes the application externally:
- HTTP routing rules
- Path-based routing
- Ready for TLS termination

### Application Features

Our sample application includes:

#### **Health Endpoints**
- `/health` - Basic health check
- `/ready` - Readiness check
- `/metrics` - Prometheus metrics

#### **Logging**
- Structured JSON logging
- Request/response logging
- Error tracking

#### **Metrics**
- Request counters
- Response time histograms
- Error rate tracking

## 🎯 Workshop Tasks

### Task 2.1: Build and Load Docker Image ✅
Follow steps 1-3 above to build and load the Docker image into Kind.

### Task 2.2: Deploy Application with Terraform ✅
Follow steps 4-6 to deploy the application using Terraform.

### Task 2.3: (Optional) Set up Ingress Controller ⚠️
Follow step 7 if you want to test ingress functionality (not required for workshop).

### Task 2.4: Test Application Endpoints ✅
Follow step 8 and use the commands below to test the application.
```bash
# Set up port forwarding (run this in background or separate terminal)
kubectl port-forward service/sample-app-service 8080:80 -n devops-app &

# Health check
curl http://localhost:8080/health

# Get application info
curl http://localhost:8080/info

# Generate some load
for i in {1..10}; do curl http://localhost:8080/; done

# Stop port forwarding when done
pkill -f "kubectl port-forward"
```

### Task 2.6: Explore Kubernetes Resources
```bash
# Describe the deployment
kubectl describe deployment sample-app -n devops-app

# View pod logs
kubectl logs -l app=sample-app -n devops-app

# Check resource usage (if metrics-server is available)
kubectl top pods -n devops-app 2>/dev/null || echo "Metrics server not available - this is normal in Kind"
```

### Task 2.7: Scale the Application
```bash
# Scale to 5 replicas
kubectl scale deployment sample-app --replicas=5 -n devops-app

# Watch the scaling
kubectl get pods -n devops-app -w
```

### Task 2.8: Update via Terraform
1. Edit `terraform.tfvars` to change replica count
2. Run `terraform plan` to see changes
3. Apply the changes with `terraform apply`

### Task 2.8: Test Rolling Deployment ✅
Test the automatic rolling deployment feature when you update the application.

```bash
# Make a small change to the application
sed -i 's/"version": "2.0.0"/"version": "2.0.1"/' app/app.py

# Rebuild the image
cd app/
docker build -t devops-sample-app:latest .
cd ..

# Apply Terraform - watch it detect the change and roll out
terraform apply

# Monitor the rolling deployment
kubectl rollout status deployment/sample-app -n devops-app

# Verify the new version is running
kubectl port-forward service/sample-app-service 8080:80 -n devops-app &
curl http://localhost:8080/info
```

## 🧪 Validation Checklist

- [ ] Docker image built successfully
- [ ] Image loaded into Kind cluster
- [ ] Terraform deployment completed
- [ ] Application pods are running (3 replicas)
- [ ] Service is accessible within cluster
- [ ] Ingress routes traffic correctly
- [ ] Health endpoints respond correctly
- [ ] Logs are being generated
- [ ] Metrics endpoint is accessible

## 🔧 Troubleshooting

### Issue: Docker build fails
```bash
# Check Docker is running
docker version

# Build with verbose output
docker build -t devops-sample-app:latest . --progress=plain

# Check build context
ls -la app/
```

### Issue: Image not loading into Kind
```bash
# Check Kind cluster exists
kind get clusters

# Verify cluster name
kubectl config current-context

# Manual load with verbose output
kind load docker-image devops-sample-app:latest --name devops-workshop -v 3
```

### Issue: Pods not starting
```bash
# Check pod status
kubectl get pods -n devops-app

# Check events
kubectl get events -n devops-app

# Check pod logs
kubectl logs <pod-name> -n devops-app
```

### Issue: Service not accessible
```bash
# Check service endpoints
kubectl get endpoints -n devops-app

# Port forward for direct access
kubectl port-forward service/sample-app-service 8080:80 -n devops-app
```

### Issue: Application not responding via port-forward
```bash
# Check if pods are ready
kubectl get pods -n devops-app

# Check service targets
kubectl describe service sample-app-service -n devops-app

# Test direct pod access
kubectl port-forward pod/<pod-name> 8080:5000 -n devops-app
```

### Issue: Ingress not working
```bash
# Check ingress status
kubectl describe ingress sample-app-ingress -n devops-app

# Note: Ingress requires an ingress controller
# For Kind, you can install nginx ingress controller:
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for ingress controller to be ready
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s
```

## 📊 Application Observability

Our application is designed with observability in mind:

### **Logging**
- All requests are logged in JSON format
- Error tracking with stack traces
- Performance metrics in logs

### **Metrics**
- Prometheus-compatible metrics endpoint
- Request counters and histograms
- Custom business metrics

### **Health Checks**
- Kubernetes-native health checking
- Graceful degradation
- Circuit breaker patterns

## 🧹 Cleanup

To remove the application (but keep the cluster):
```bash
terraform destroy
```

## 📚 Key Takeaways

1. **Infrastructure as Code**: Applications can be deployed declaratively
2. **Kubernetes Integration**: Terraform works seamlessly with Kubernetes
3. **Observability**: Applications should be designed for monitoring
4. **Best Practices**: Health checks, resource limits, and proper labeling

## 🎯 Next Steps

Excellent! You now have a running application that's ready for monitoring.

**Next Section:** [04-observability-concepts](../04-observability-concepts/README.md) - Learn about observability principles

---

**💡 Pro Tip:** Always design applications with observability in mind from the start - it's much harder to add later!
