# DevOps Course: Infrastructure as Code & Observability

A 4-hour hands-on course that teaches you to build and monitor infrastructure using modern DevOps tools.

## 🚀 Before You Start

### Install Required Tools

You'll need these tools installed on your computer:

**1. Docker Desktop**
- macOS: Download from [docker.com](https://www.docker.com/products/docker-desktop) or run `brew install --cask docker`
- Linux: `curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh`
- Windows: Download from [docker.com](https://www.docker.com/products/docker-desktop) (ensure WSL2 is enabled)

**2. Terraform**
- macOS: `brew install terraform`
- Linux: `sudo apt update && sudo apt install terraform`
- Windows: Download from [terraform.io](https://www.terraform.io/downloads)

**3. kubectl**
- macOS: `brew install kubectl`
- Linux: `curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && sudo install kubectl /usr/local/bin/`
- Windows: Download from [kubernetes.io](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/)

**4. Kind (Kubernetes in Docker)**
- macOS: `brew install kind`
- Linux: `curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64 && chmod +x ./kind && sudo mv ./kind /usr/local/bin/`
- Windows: Download from [kind.sigs.k8s.io](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)

### Verify Installation

```bash
# Check all tools are installed
./scripts/verify-setup.sh
```

**Expected output:** All tools should show ✅ green checkmarks.

---

## 📅 Course Schedule (4 Hours Total)

### **Part 1: Infrastructure as Code (2 hours)**

**Lecture: Infrastructure as Code Concepts (45 minutes)**
- What is Infrastructure as Code and why it matters
- Traditional vs. IaC approaches  
- Terraform fundamentals

**Hands-on: Build & Deploy (45 minutes)**
- Create Kubernetes cluster with Terraform
- Build and deploy a sample application
- Understand the deployment process

### **Break (30 minutes)**

### **Part 2: Monitoring & Observability (1.5 hours)**

**Lecture: Monitoring Concepts (45 minutes)**  
- The three pillars of observability
- Metrics, logs, and traces explained
- Why monitoring matters for applications

**Hands-on: Monitoring Stack (45 minutes)**
- Deploy Prometheus, Grafana, and Loki
- Create dashboards to visualize your application
- Set up alerts and understand system health

---

## 🛠️ Course Tasks

Complete these tasks in order:

### **Task 1: Create Kubernetes Cluster**
**What you'll do:** Use Terraform to create a local Kubernetes cluster  
**Time:** 25 minutes  
**Location:** `01-cluster-setup/`

### **Task 2: Deploy Application** 
**What you'll do:** Build a Docker image and deploy it to Kubernetes  
**Time:** 25 minutes  
**Location:** `02-app-deployment/`

### **Task 3: Set up Monitoring**
**What you'll do:** Deploy monitoring tools to track your application  
**Time:** 25 minutes  
**Location:** `03-monitoring/`

### **Task 4: Create Dashboards**
**What you'll do:** Build visual dashboards to monitor system health  
**Time:** 20 minutes  
**Location:** `04-dashboards/`

---

## 🎯 What You'll Learn

By the end of this course, you'll understand:

- **Infrastructure as Code**: How to manage infrastructure using code instead of manual processes
- **Container Orchestration**: How Kubernetes manages your applications
- **Application Deployment**: How to build and deploy applications reliably  
- **System Monitoring**: How to observe and troubleshoot your applications
- **DevOps Workflow**: The complete cycle from code to production monitoring

---

## 🚀 Ready to Start?

1. **Verify your tools** are installed: `./scripts/verify-setup.sh`
2. **Start with Task 1**: Open `01-cluster-setup/README.md`
3. **Follow each task in order** - they build on each other
4. **Ask questions** - learning DevOps is a journey!

**Let's build something awesome! 🎉**