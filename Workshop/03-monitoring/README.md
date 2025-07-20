# Task 3: Set up Monitoring

**What you'll do:** Deploy monitoring tools to track your application  
**Time:** 25 minutes

## Why We Need This

Your application is running, but how do you know if it's healthy? What if it crashes? What if it becomes slow? 

**Monitoring** lets you see inside your running applications and infrastructure. It's like having a dashboard for your car - you can see speed, fuel, temperature, etc.

We'll install:
- **Prometheus** - Collects numbers about your system (CPU usage, response times, etc.)
- **Grafana** - Creates visual dashboards from those numbers
- **Loki** - Collects and stores your application logs

---

## Step 1: Navigate and Explore

```bash
# Go to the monitoring directory
cd ../03-monitoring

# See what we have
ls -la
```

**What you'll see:**
- `main.tf` - Terraform configuration to deploy monitoring tools
- `variables.tf` - Settings we can customize
- `outputs.tf` - Connection information for monitoring tools
- `alloy-config.alloy` - Configuration for log collection
- `validate-monitoring.sh` - Script to check everything is working
- `troubleshoot.sh` - Help if things go wrong

## Step 2: Initialize Terraform

```bash
# Copy the example configuration
cp terraform.tfvars.example terraform.tfvars

# Initialize Terraform for monitoring deployment
terraform init
```

**What this does:** Downloads Helm (Kubernetes package manager) provider and Prometheus/Grafana "charts" (pre-built packages).

## Step 3: See What Will Be Created

```bash
# Preview the monitoring stack
terraform plan
```

**What you'll see:** Terraform will create:
- Prometheus server (metrics collection)
- Grafana server (dashboards and visualization)  
- Loki server (log collection)
- All necessary networking and storage

## Step 4: Deploy the Monitoring Stack

```bash
# Deploy all monitoring tools
terraform apply
```

**Type `yes` when prompted.**

**What this does:**
- Installs Prometheus to collect metrics from your cluster and application
- Installs Grafana with dashboards to visualize the data
- Installs Loki to collect and store application logs
- Configures them all to work together

**This takes 3-4 minutes** - it's downloading and starting several applications.

## Step 5: Wait for Everything to Start

```bash
# Check if monitoring pods are running
kubectl get pods -n monitoring
```

**Wait until all pods show "Running" status.** This may take 2-3 minutes.

**What you should see:**
```
NAME                                  READY   STATUS    RESTARTS   AGE
grafana-xxxxxxxxx-xxxxx               1/1     Running   0          2m
prometheus-server-xxxxxxxxx-xxxxx     1/1     Running   0          2m
loki-xxxxxxxxx-xxxxx                  1/1     Running   0          2m
...
...
...
```

## Step 6: Access Grafana Dashboard

**Easy way (recommended for beginners):**
```bash
# Use our validation script to set everything up
./validate-monitoring.sh
```

**This script will:**
- Check that all monitoring components are running
- Get the Grafana password for you
- Set up port forwarding to both Grafana and Prometheus
- Give you the login details

**Manual way (if you prefer):**
```bash
# Get the Grafana admin password
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode && echo
```

**Copy this password** - you'll need it to log in.

```bash
# Set up port forwarding to Grafana
kubectl port-forward service/grafana 3000:80 -n monitoring
```

**Keep this terminal open** for the port forwarding.

**Open your web browser** and go to: `http://localhost:3000`

**Log in with:**
- Username: `admin`  
- Password: (the password you copied above)

## Step 7: Explore Your Monitoring

**In Grafana:**

1. **Click "Dashboards"** in the left menu
2. **Look for pre-installed dashboards** (there should be some basic ones)
3. **Click on any dashboard** to see metrics from your cluster

**You should see:**
- CPU and memory usage of your cluster
- Network traffic
- Number of running pods
- Application response times

## Step 8: Check Prometheus

**Open a new terminal:**
```bash
# Access Prometheus directly
kubectl port-forward service/prometheus-server 9090:80 -n monitoring
```

**Open another browser tab** to: `http://localhost:9090`

**Try some queries:**
- Type `up` and click "Execute" - shows which services are being monitored
- Type `container_cpu_usage_seconds_total` - shows CPU usage
- Type `kube_pod_info` - shows information about your pods

---

## What Just Happened?

1. **You deployed a complete monitoring stack** - Professional-grade tools used by companies worldwide
2. **Metrics are being collected** - Prometheus is gathering data about your cluster and application every 15 seconds
3. **Dashboards are ready** - Grafana is visualizing this data in real-time graphs
4. **Logs are being collected** - Loki is storing application logs for troubleshooting

## 🎯 Task Complete!

You now have:
- ✅ Prometheus collecting metrics from your cluster and application
- ✅ Grafana providing visual dashboards  
- ✅ Loki collecting application logs
- ✅ A complete observability platform for your applications
- ✅ Understanding of monitoring fundamentals

**Ready for the final task?** Go to `../04-dashboards/README.md`

---

## Troubleshooting

**Quick Fix:** Run the troubleshooting script first:
```bash
./troubleshoot.sh
```

**Manual troubleshooting:**

**Problem:** Pods stuck in "Pending"  
**Solution:** Wait 2-3 minutes - monitoring tools need time to download and start

**Problem:** Can't access Grafana  
**Solution:** Make sure port-forward is running and try `http://localhost:3000`

**Problem:** Grafana login fails  
**Solution:** Re-run the password command and copy it exactly

**Problem:** No data in dashboards  
**Solution:** Wait 2-3 minutes for metrics to be collected, then refresh the dashboard
