# Task 4: Create Grafana Dashboards

## 🎯 Objective

Create comprehensive Grafana dashboards to visualize metrics and logs from our application and infrastructure. Learn dashboard design principles and best practices for effective monitoring.

## ⏱️ Time: 45 minutes

## 📚 What You'll Learn

- Dashboard design principles
- Creating effective visualizations
- Combining metrics and logs in dashboards
- Setting up alerts from dashboards
- Dashboard sharing and collaboration
- Best practices for production dashboards

## 🛠️ Prerequisites

- Running monitoring stack (Grafana, Prometheus, Loki) from Task 3
- Deployed application from Task 2
- Basic understanding of Prometheus metrics and Grafana concepts

## 📁 Files Overview

```
06-grafana-dashboards/
├── README.md              # This file
├── deploy-enhanced-setup.sh # Dashboard import script
└── dashboards/           # Pre-built dashboard JSON files
    ├── application-overview.json
    ├── infrastructure-monitoring.json
    ├── log-analysis.json
    └── sre-golden-signals.json
```

## 🎨 Dashboard Design Principles

### **1. Know Your Audience**
- **Developers**: Focus on application performance, errors, logs
- **Operations**: Infrastructure health, resource usage, alerts
- **Business**: User experience, feature adoption, SLAs

### **2. Follow the Inverted Pyramid**
- **Top**: High-level summary (health, SLOs)
- **Middle**: Key metrics and trends
- **Bottom**: Detailed drill-down information

### **3. Use the Right Visualization**
- **Time Series**: Trends over time
- **Single Stat**: Current values, SLIs
- **Gauge**: Utilization, percentages
- **Heatmap**: Distribution analysis
- **Table**: Lists, rankings

### **4. Color Psychology**
- **Green**: Good, healthy, normal
- **Yellow/Orange**: Warning, attention needed
- **Red**: Critical, error, failure
- **Blue**: Information, neutral metrics

## 🚀 Step-by-Step Guide

### Step 1: Quick Setup (Recommended) 🎯

**For automatic dashboard import and setup:**

```bash
# Navigate to dashboards directory
cd 06-grafana-dashboards

# Run the automated dashboard import script
./deploy-enhanced-setup.sh
```

This script will:
- ✅ Verify your application is running
- ✅ Set up port forwarding to Grafana
- ✅ Import all 4 dashboards into Grafana
- ✅ Generate test traffic to populate dashboards
- ✅ Display access credentials and links

**The script provides immediate access to:**
- 📊 Grafana with imported dashboards: `http://localhost:3000`
- 📈 Application: `http://localhost:8080`

**Skip to Step 4 if using the automated script.**

### Step 2: Access Grafana (Manual Setup)

```bash
# Port forward to Grafana
kubectl port-forward service/grafana 3000:80 -n monitoring

# Get admin password
kubectl get secret grafana -o jsonpath="{.data.admin-password}" -n monitoring | base64 -d && echo
```

Open http://localhost:3000
- Username: admin
- Password: (from command above)

### Step 3: Import Pre-built Dashboards

#### **Method 1: Manual Import**
1. Go to Dashboards → Import
2. Copy the JSON content from each dashboard file
3. Paste and import

#### **Method 2: Via API**
```bash
# Set Grafana credentials
GRAFANA_URL="http://admin:$(kubectl get secret grafana -o jsonpath="{.data.admin-password}" -n monitoring | base64 -d)@localhost:3000"

# Import application overview dashboard
curl -X POST \
  $GRAFANA_URL/api/dashboards/db \
  -H "Content-Type: application/json" \
  -d @dashboards/application-overview.json
```

### Step 4: Explore the Dashboards

#### **1. Application Overview Dashboard**
- Request rate and error rate
- Response time percentiles  
- HTTP status code distribution
- Requests by endpoint

#### **2. Infrastructure Monitoring Dashboard**
- Cluster resource usage
- Node health and capacity
- Pod resource consumption
- Network and storage metrics

#### **3. Log Analysis Dashboard**
- Log volume over time by level (INFO, WARN, ERROR)
- Recent error and warning logs
- Request correlation analysis
- Structured log parsing and filtering

#### **4. SRE Golden Signals Dashboard**
- **Latency**: Response time percentiles (50th, 90th, 95th, 99th)
- **Traffic**: Request rate over time by status
- **Errors**: Error rate trends and thresholds
- **Saturation**: CPU and memory usage

### Step 5: Test Application Features

The application includes these features for monitoring:

```bash
# Test application endpoints
curl http://localhost:8080/health        # Health check
curl http://localhost:8080/info          # Application information
curl http://localhost:8080/users         # Users endpoint
curl http://localhost:8080/users/1       # Individual user
curl http://localhost:8080/orders        # Orders endpoint
curl http://localhost:8080/error         # Trigger test error
curl http://localhost:8080/timeout       # Trigger slow response

# Test POST endpoint
curl -X POST http://localhost:8080/orders \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1, "product": "Monitor", "amount": 299.99}'

# Check metrics
curl http://localhost:8080/metrics | grep http_
```

**Application Features:**
- ✅ **Structured JSON logging** with correlation IDs
- ✅ **Prometheus metrics** (request counters, histograms, error counters)
- ✅ **Request correlation** across all logs
- ✅ **Health and readiness checks**
- ✅ **Simulated real-world scenarios** (slow queries, errors)
- ✅ **Multiple endpoints** for testing

### Step 6: Create a Custom Dashboard (Optional)

Let's create a simple custom dashboard:

1. **Create New Dashboard**
   - Click "+ Create Dashboard"
   - Add Panel

2. **Add Request Rate Panel**
   ```promql
   # Query
   rate(http_requests_total[5m])
   
   # Title: "Request Rate"
   # Type: Time Series
   # Unit: requests/sec
   ```

3. **Add Error Rate Panel**
   ```promql
   # Query
   rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) * 100
   
   # Title: "Error Rate %"
   # Type: Stat
   # Unit: percent (0.0-1.0)
   # Thresholds: Green < 1%, Yellow < 5%, Red >= 5%
   ```

4. **Add Response Time Panel**
   ```promql
   # Query 1: 50th percentile
   histogram_quantile(0.5, rate(http_request_duration_seconds_bucket[5m]))
   
   # Query 2: 95th percentile
   histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
   
   # Query 3: 99th percentile
   histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))
   
   # Title: "Response Time Percentiles"
   # Type: Time Series
   # Unit: seconds
   ```

5. **Add Log Volume Panel**
   ```logql
   # Query
   rate({namespace="devops-app"}[1m])
   
   # Title: "Log Rate"
   # Type: Time Series
   # Unit: logs/sec
   ```

## 🎯 Workshop Tasks

### Task 4.1: Import Dashboards ✅
Run the automated dashboard import script or follow manual steps above.

### Task 4.2: Explore Pre-built Dashboards
1. **Application Overview**: Monitor request rates, errors, and response times
2. **Infrastructure Monitoring**: Check cluster health and resource usage  
3. **Log Analysis**: Explore structured logs and correlation IDs
4. **SRE Golden Signals**: Understand the four key metrics for service health

### Task 4.3: Test Application Features
1. **Generate Traffic**: Use various endpoints to create metrics
2. **Test Error Scenarios**: Hit `/error` endpoint to see error tracking
3. **Check Correlation IDs**: Verify request correlation in logs
4. **Monitor Performance**: Observe response time variations

### Task 4.4: Explore Dashboard Features
1. **Time Range Selection**: Try different time ranges
2. **Refresh Intervals**: Set auto-refresh
3. **Variable Usage**: Explore template variables (if available)
4. **Drill-down**: Click on metrics to explore

### Task 4.5: Create Your Own Panel
Add a new panel to the Application Overview dashboard:
- Panel showing top 10 endpoints by request count
- Use a bar gauge visualization
- Add appropriate thresholds and colors

### Task 4.6: Set Up Dashboard Alerts
1. Edit the Error Rate panel
2. Go to Alert tab
3. Create an alert rule:
   - Condition: Error rate > 5%
   - Evaluation: Every 1 minute
   - For: 2 minutes

### Task 4.7: Create a Custom Dashboard
Build a dashboard for your specific use case:
- Business metrics (if applicable)
- Custom application metrics
- Log-based metrics

## 🧪 Validation Checklist

- [ ] All pre-built dashboards imported successfully
- [ ] Data is displaying correctly in all panels
- [ ] Time range controls work properly
- [ ] Template variables function correctly
- [ ] Custom dashboard created
- [ ] Alert rule configured and working
- [ ] Dashboard sharing/export works

## 📊 Dashboard Examples

### **Application Performance Dashboard**

**Top Row - Key Metrics**
```
┌─────────────────┬─────────────────┬─────────────────┬─────────────────┐
│   Request Rate  │   Error Rate    │  Avg Response   │   Active Users  │
│      250/s      │      0.5%       │     120ms       │      1,234      │
│   📈 +5.2%      │   🟢 Normal     │   ⚠️ +10ms      │   📊 Stable     │
└─────────────────┴─────────────────┴─────────────────┴─────────────────┘
```

**Middle Row - Trends**
```
┌─────────────────────────────────────┬─────────────────────────────────────┐
│         Request Rate Over Time       │       Response Time Percentiles     │
│                                     │                                     │
│  300 ┤                              │  500ms ┤                            │
│  250 ┤     ╭─╮                      │  400ms ┤           P99               │
│  200 ┤   ╭─╯ ╰─╮                    │  300ms ┤     ╭─────╯                 │
│  150 ┤ ╭─╯     ╰──╮                 │  200ms ┤   ╭─╯      P95              │
│  100 ┤─╯          ╰─               │  100ms ┤───╯        P50              │
│                                     │                                     │
└─────────────────────────────────────┴─────────────────────────────────────┘
```

**Bottom Row - Details**
```
┌─────────────────────────────────────┬─────────────────────────────────────┐
│           Top Endpoints             │           Error Details             │
│                                     │                                     │
│  /api/users        │ 150 req/s ████ │  500 Internal Error │ 5 errors     │
│  /api/orders       │ 80 req/s  ███  │  404 Not Found      │ 3 errors     │
│  /health           │ 20 req/s  █    │  503 Service Unavail│ 1 error      │
│                                     │                                     │
└─────────────────────────────────────┴─────────────────────────────────────┘
```

### **Infrastructure Dashboard**

**Resource Usage Overview**
```
┌─────────────────┬─────────────────┬─────────────────┬─────────────────┐
│   CPU Usage     │  Memory Usage   │   Disk Usage    │  Network I/O    │
│      65%        │      78%        │      45%        │    125 MB/s     │
│   🟢 Normal     │   ⚠️ High       │   🟢 Good       │   📈 +15%       │
└─────────────────┴─────────────────┴─────────────────┴─────────────────┘
```

## 🔧 Advanced Dashboard Features

### **1. Template Variables**
Create dynamic dashboards with variables:
```
# Variable: namespace
Query: label_values(kube_pod_info, namespace)

# Variable: pod
Query: label_values(kube_pod_info{namespace="$namespace"}, pod)

# Use in queries:
rate(http_requests_total{namespace="$namespace", pod=~"$pod"}[5m])
```

### **2. Annotations**
Add context to your dashboards:
- Deployment events
- Incident markers
- Maintenance windows

### **3. Links and Drill-downs**
Connect dashboards for investigation workflows:
- Link from high-level to detailed dashboards
- Include runbook links
- Add log exploration links

### **4. Dashboard Sharing**
- Export as JSON for version control
- Create dashboard snapshots
- Set up dashboard folders and permissions

## 🚨 Alerting Best Practices

### **Alert Design Principles**
1. **Alert on symptoms, not causes**
2. **Make alerts actionable**
3. **Avoid alert fatigue**
4. **Include context in alert messages**

### **Example Alert Rules**
```yaml
# High error rate
- alert: HighErrorRate
  expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
  for: 2m
  annotations:
    summary: "High error rate detected"
    description: "Error rate is {{ $value }} errors/sec"

# Response time SLA violation
- alert: ResponseTimeSLAViolation
  expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 0.5
  for: 5m
  annotations:
    summary: "95th percentile response time above SLA"
    description: "95th percentile response time is {{ $value }}s"
```

## 📚 Dashboard Maintenance

### **Regular Tasks**
1. **Review and Update**: Keep dashboards current with application changes
2. **Performance Optimization**: Optimize slow queries
3. **User Feedback**: Gather feedback from dashboard users
4. **Documentation**: Maintain dashboard documentation

### **Version Control**
Store dashboard JSON in Git:
```bash
# Export dashboard
curl -s "$GRAFANA_URL/api/dashboards/uid/$DASHBOARD_UID" | jq '.dashboard' > dashboards/my-dashboard.json

# Commit to Git
git add dashboards/my-dashboard.json
git commit -m "Update application dashboard"
```

## 🧹 Cleanup

Dashboards persist in Grafana - no cleanup needed unless removing the entire monitoring stack.

## 📚 Key Takeaways

1. **Design for Users**: Know who will use the dashboard and what they need
2. **Start Simple**: Begin with key metrics and add complexity gradually
3. **Use Standards**: Follow established patterns and conventions
4. **Make it Actionable**: Every metric should lead to an action
5. **Iterate**: Dashboards should evolve with your understanding

## 🎉 Workshop Complete!

Congratulations! You've successfully:
- ✅ Learned IaC concepts and Terraform
- ✅ Provisioned Kubernetes infrastructure
- ✅ Deployed applications via Terraform
- ✅ Implemented comprehensive observability
- ✅ Created meaningful dashboards and alerts

## 🎯 Next Steps

### **Continue Learning**
- Explore advanced Prometheus queries (PromQL)
- Learn about service mesh observability (Istio)
- Dive into distributed tracing (Jaeger, OpenTelemetry)
- Study SRE practices and SLO implementation

### **Apply in Production**
- Implement in your organization
- Start with pilot projects
- Build runbooks and documentation
- Train your team

---

**🎉 Congratulations on completing the DevOps Observability and IaC Workshop!**
