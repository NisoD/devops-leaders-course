# Task 3: Deploy Monitoring Stack

## 🎯 Objective

Deploy a complete observability stack including Prometheus, Grafana, Loki, and Grafana Alloy using Helm charts. This will provide metrics collection, visualization, and log aggregation for our applications.

## ⏱️ Time: 45 minutes

## 🚀 Quick Start

**TL;DR**: After deployment, run `./validate-monitoring.sh` for automated validation and easy access to all services!

## 📚 What You'll Learn

- Deploying monitoring infrastructure with Helm
- Configuring Prometheus for metrics collection
- Setting up Grafana for visualization
- Implementing Loki for log aggregation
- Configuring Grafana Alloy for data collection
- Understanding monitoring stack architecture

## 🛠️ Prerequisites

- Running Kubernetes cluster from Task 1 (Kind cluster)
- Deployed application from Task 2
- Helm installed
- kubectl configured with cluster context

**Verification:**
```bash
# Check cluster status
kubectl get nodes

# Check if application is running
kubectl get pods -n devops-app

# Verify Helm is working
helm version
```

## 📁 Files Overview

```
05-monitoring-stack/
├── README.md              # This file
├── main.tf               # Terraform configuration
├── variables.tf          # Input variables
├── outputs.tf            # Output values
├── versions.tf           # Provider requirements
├── terraform.tfvars.example
├── validate-monitoring.sh # 🚀 Validation & setup script
├── troubleshoot.sh       # Troubleshooting script
├── helm-charts/          # Helm chart configurations
│   ├── prometheus/
│   ├── grafana/
│   ├── loki/
│   └── alloy/
└── configs/              # Configuration files
    ├── prometheus.yaml
    ├── grafana-datasources.yaml
    └── alloy-config.yaml
```

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Applications  │───▶│  Grafana Alloy  │───▶│   Prometheus    │
│                 │    │   (Collector)   │    │   (Metrics)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       ▼                       │
         │              ┌─────────────────┐              │
         └─────────────▶│      Loki       │              │
                        │     (Logs)      │              │
                        └─────────────────┘              │
                                 │                       │
                                 ▼                       ▼
                        ┌─────────────────────────────────────┐
                        │            Grafana                  │
                        │        (Visualization)              │
                        └─────────────────────────────────────┘
```

## 🚀 Step-by-Step Guide

### Step 1: Install Helm (if not already installed)

```bash
# Check if Helm is installed
helm version

# If not installed, install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### Step 2: Add Helm Repositories

```bash
# Add required Helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

### Step 3: Deploy the Monitoring Stack

```bash
# Navigate to monitoring stack directory
cd 05-monitoring-stack

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Deploy the monitoring stack
terraform apply
```

**Expected deployment time:** 2-3 minutes for all components.

**If deployment fails:**
1. Check the troubleshooting section below
2. Run the troubleshooting script: `./troubleshoot.sh`
3. Use `helm status <release-name> -n monitoring` to investigate
4. Clean up failed releases and retry

### Step 4: Run the Validation Script 🚀

**For a quick validation and automated setup of all port-forwards:**

```bash
# Run the comprehensive validation script
./validate-monitoring.sh
```

This script will:
- ✅ Validate all monitoring components are running
- ✅ Check Helm releases and pod status
- ✅ Test service endpoints
- ✅ Automatically setup port-forwards for all services
- ✅ Test all endpoints for accessibility
- ✅ Display Grafana credentials
- ✅ Show quick access guide and tips
- ✅ Keep port-forwards running in the background

**The script provides immediate access to:**
- 📊 Grafana Dashboard: `http://localhost:3000`
- 📈 Prometheus UI: `http://localhost:9090`
- 📋 Loki API: `http://localhost:3100`
- 🔄 Sample App: `http://localhost:8080`

**Note:** The script will run continuously to maintain port-forwards. Press `Ctrl+C` to stop and cleanup.

### Step 5: Manual Verification (Alternative)

If you prefer manual verification instead of using the script:

```bash
# Check all monitoring pods
kubectl get pods -n monitoring

# Check services
kubectl get services -n monitoring

# Wait for all pods to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n monitoring --timeout=300s
```

### Step 6: Access Grafana Dashboard

```bash
# Get Grafana admin password
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

# Port forward to access Grafana
kubectl port-forward service/grafana 3000:80 -n monitoring
```

Open http://localhost:3000 in your browser
- Username: admin
- Password: (from the command above)

## 🔍 Understanding the Stack Components

### **1. Prometheus**
- **Purpose**: Metrics collection and storage
- **Port**: 9090
- **Features**:
  - Service discovery for Kubernetes
  - PromQL query language
  - Built-in alerting rules
  - Data retention configuration

### **2. Grafana**
- **Purpose**: Visualization and dashboards
- **Port**: 3000
- **Features**:
  - Pre-configured data sources
  - Built-in dashboards
  - Alerting capabilities
  - User management

### **3. Loki**
- **Purpose**: Log aggregation and storage
- **Port**: 3100
- **Features**:
  - Label-based log indexing
  - LogQL query language
  - Integration with Grafana
  - Cost-effective log storage

### **4. Grafana Alloy**
- **Purpose**: Telemetry data collection
- **Features**:
  - Metrics collection from applications
  - Log forwarding to Loki
  - Service discovery
  - Data transformation

## 🎯 Workshop Tasks

### Task 3.1: Deploy the Stack ✅
Follow the steps above to deploy all monitoring components.

### Task 3.1.1: Run Validation Script 🚀
**Recommended: Use the automated validation script for easy setup:**

```bash
# Run the comprehensive validation and setup script
./validate-monitoring.sh
```

This will automatically:
- Validate all components are running
- Setup all necessary port-forwards
- Test endpoints
- Display access credentials
- Show quick access guide

**Skip to Task 3.3 if using the validation script** (it handles all port-forwarding automatically).

### Task 3.2: Explore Prometheus

```bash
# Port forward to Prometheus (skip if using validation script)
kubectl port-forward service/prometheus-server 9090:80 -n monitoring
```

Open http://localhost:9090 and explore:
- Targets page (Status → Targets)
- Metrics browser
- Try some PromQL queries:
  ```promql
  up
  rate(http_requests_total[5m])
  container_memory_usage_bytes
  ```

### Task 3.3: Explore Grafana

In Grafana (http://localhost:3000):
1. Check data sources (Connections → Data Sources)
2. Import a dashboard (+ → Import → 315 for Kubernetes cluster monitoring)
3. Explore existing dashboards

### Task 3.4: Verify Metrics Collection

**If using the validation script**, all port-forwards are already active. Otherwise, set them up manually:

```bash
# Port forward Prometheus to access metrics API (skip if using validation script)
kubectl port-forward service/prometheus-server 9090:80 -n monitoring

# Check if your application metrics are being scraped
curl http://localhost:9090/api/v1/query?query=up{job="sample-app"}

# Port forward your application to access its metrics endpoint (skip if using validation script)
kubectl port-forward service/sample-app-service 8080:80 -n devops-app

# Check application metrics
curl http://localhost:8080/metrics
```

**Quick verification commands:**
```bash
# Test all endpoints (if using validation script)
curl http://localhost:9090/api/v1/query?query=up
curl http://localhost:8080/health
curl http://localhost:8080/metrics
curl http://localhost:3100/ready
```

### Task 3.5: Explore Logs in Loki

In Grafana:
1. Go to Explore
2. Select Loki data source
3. Try log queries:
   ```logql
   {namespace="devops-app"}
   {namespace="devops-app"} |= "error"
   rate({namespace="devops-app"}[5m])
   ```

## 🧪 Validation Checklist

**Quick validation**: Run `./validate-monitoring.sh` to automatically check all items below.

**Manual validation:**
- [ ] All monitoring pods are running
- [ ] Prometheus is scraping targets successfully
- [ ] Grafana is accessible and shows data
- [ ] Loki is receiving logs
- [ ] Alloy is collecting telemetry data
- [ ] Application metrics are visible in Prometheus
- [ ] Application logs are visible in Loki

**Using validation script:**
- [ ] Script validates all components
- [ ] Port-forwards are setup automatically
- [ ] All endpoints are accessible
- [ ] Grafana credentials are displayed

## 🔧 Troubleshooting

### Issue: Grafana Alloy deployment timeout

If you see an error like:
```
Warning: Helm release "" was created but has a failed status. Use the `helm` command to investigate the error, correct it, then run Terraform again.
Error: context deadline exceeded
```

This indicates that the Alloy deployment is taking too long or has failed.

**Common causes:**
1. **Config-reloader image pull issues**: The `ghcr.io/jimmidyson/configmap-reload:v0.12.0` image may fail to pull due to certificate issues in Kind clusters
2. **Configuration errors**: Invalid Alloy configuration syntax
3. **Resource constraints**: Insufficient cluster resources

**Investigation Steps:**
```bash
# Check the status of the Alloy release
helm status alloy -n monitoring

# Check Alloy pods
kubectl get pods -n monitoring -l app.kubernetes.io/name=alloy

# Check pod logs and events
kubectl describe pod <alloy-pod-name> -n monitoring
kubectl logs -n monitoring -l app.kubernetes.io/name=alloy

# Check events
kubectl get events -n monitoring --sort-by='.lastTimestamp' | grep -i alloy
```

**Solution:**
```bash
# Remove the failed Alloy release
helm uninstall alloy -n monitoring

# Clean up any stuck resources
kubectl delete pods -n monitoring -l app.kubernetes.io/name=alloy --grace-period=0 --force

# Run Terraform again to redeploy (now with config-reloader disabled)
terraform apply
```

**Alternative: Deploy without Alloy (for workshop purposes)**
If Alloy continues to fail, you can modify the Terraform configuration to skip Alloy deployment by commenting out the Alloy resource in `main.tf`:

```bash
# Edit main.tf and comment out the Alloy resource
# Find the section starting with 'resource "helm_release" "alloy"' and add # at the beginning of each line

# Or use this command to comment it out automatically:
sed -i.bak '/resource "helm_release" "alloy"/,/^}/s/^/# /' main.tf

# Then apply without Alloy
terraform apply
```

**Note:** The workshop can continue without Alloy - Prometheus will still collect metrics directly from services.

### Issue: Loki Helm chart configuration error

If you see an error like:
```
Error: template: loki/templates/single-binary/statefulset.yaml:44:28: executing "loki/templates/single-binary/statefulset.yaml" at <include (print .Template.BasePath "/config.yaml") .>: error calling include: template: loki/templates/config.yaml:19:7: executing "loki/templates/config.yaml" at <include "loki.calculatedConfig" .>: error calling include: template: loki/templates/_helpers.tpl:451:35: executing "loki.calculatedConfig" at <.Values.loki.config>: wrong type for value; expected string; got map[string]interface {}
```

This is a known issue with newer versions of the Loki Helm chart. The configuration has been updated to use the newer format.

**Solution:**
```bash
# Destroy the current deployment
terraform destroy -target=helm_release.loki

# Apply again with the updated configuration
terraform apply
```

### Issue: Pods not starting

```bash
# Check pod status
kubectl get pods -n monitoring

# Describe problematic pods
kubectl describe pod <pod-name> -n monitoring

# Check events
kubectl get events -n monitoring --sort-by='.lastTimestamp'
```

### Issue: Prometheus not scraping targets

```bash
# Check Prometheus configuration
kubectl get configmap prometheus-server -n monitoring -o yaml

# Check service discovery
kubectl get servicemonitor -n monitoring
```

### Issue: Grafana not showing data

```bash
# Check Grafana logs
kubectl logs deployment/grafana -n monitoring

# Verify data source configuration
kubectl get configmap grafana-datasources -n monitoring -o yaml
```

### Issue: Loki not receiving logs

```bash
# Check Alloy configuration
kubectl get configmap alloy-config -n monitoring -o yaml

# Check Alloy logs
kubectl logs daemonset/alloy -n monitoring
```

## 📊 Default Dashboards

After deployment, you'll have access to several pre-configured dashboards:

### **Infrastructure Dashboards**
- Kubernetes Cluster Overview
- Node Exporter Full
- Pod Resource Usage

### **Application Dashboards**
- Application Performance Monitoring
- HTTP Request Metrics
- Error Rate Analysis

### **Log Dashboards**
- Log Volume Analysis
- Error Log Investigation
- Application Request Logs

## ⚙️ Configuration Details

### **Prometheus Configuration**
- **Scrape Interval**: 15 seconds
- **Retention**: 15 days
- **Storage**: 10GB persistent volume
- **Service Discovery**: Kubernetes pods and services

### **Grafana Configuration**
- **Data Sources**: Prometheus and Loki (pre-configured)
- **Plugins**: Essential visualization plugins
- **Alerting**: Email and webhook notifications
- **Persistence**: Dashboard storage enabled

### **Loki Configuration**
- **Retention**: 7 days
- **Storage**: 5GB persistent volume
- **Index**: Labels only (cost-effective)
- **Compression**: Enabled

## 🧹 Cleanup

To remove the monitoring stack:
```bash
terraform destroy
```

## 📚 Key Takeaways

1. **Infrastructure as Code**: Monitoring infrastructure can be deployed declaratively
2. **Helm Integration**: Terraform works well with Helm for complex deployments
3. **Service Discovery**: Kubernetes-native service discovery simplifies configuration
4. **Data Sources**: Proper data source configuration is crucial for observability
5. **Persistence**: Monitoring data should be persisted across restarts

## 🎯 Next Steps

Excellent! You now have a complete monitoring stack running.

**Next Task:** [06-grafana-dashboards](../06-grafana-dashboards/README.md) - Create comprehensive dashboards and visualizations

---

**💡 Pro Tip:** The monitoring stack deployment might take a few minutes - perfect time for a coffee break! ☕
