# Task 1: Provision Kubernetes Cluster with Terraform

## 🎯 Objective

Learn how to provision a Kubernetes cluster using Terraform and the Kind provider. Kind (Kubernetes in Docker) allows us to run Kubernetes clusters locally using Docker containers as nodes.

## ⏱️ Time: 30 minutes

## 📚 What You'll Learn

- Setting up Terraform providers
- Configuring Kind clusters via Terraform
- Understanding Terraform state management
- Working with Kubernetes contexts

## 🛠️ Prerequisites

- Docker installed and running
- Terraform installed (>= 1.0)
- kubectl installed
- Kind installed (Kubernetes in Docker)

**Installation Check:**
```bash
# Run from the workshop root directory
./scripts/verify-setup.sh
```

## 📁 Files Overview

```
02-terraform-k8s/
├── README.md           # This file
├── main.tf            # Main Terraform configuration
├── variables.tf       # Input variables
├── outputs.tf         # Output values
├── versions.tf        # Provider requirements
├── terraform.tfvars.example  # Example variables
└── kind-config.yaml   # Kind cluster configuration
```

## 🚀 Step-by-Step Guide

### Step 1: Understand the Configuration

First, let's examine our Terraform configuration files:

#### **versions.tf** - Provider Requirements
This file specifies which providers we need and their versions.

#### **variables.tf** - Input Variables
Defines configurable parameters for our infrastructure.

#### **main.tf** - Main Configuration
Contains the actual infrastructure resources.

#### **outputs.tf** - Output Values
Defines what information to display after provisioning.

### Step 2: Initialize Terraform

```bash
# Navigate to this directory
cd 02-terraform-k8s

# Initialize Terraform (downloads providers)
terraform init
```

**Expected Output:**
```
Initializing the backend...
Initializing provider plugins...
- Finding tehcyx/kind versions matching "~> 0.4"...
- Installing tehcyx/kind v0.4.0...
Terraform has been successfully initialized!
```

### Step 3: Review the Plan

```bash
# Create a copy of the example variables file
cp terraform.tfvars.example terraform.tfvars

# Review what Terraform will create
terraform plan
```

This shows you exactly what infrastructure will be created before you apply it.

### Step 4: Apply the Configuration

```bash
# Create the infrastructure
terraform apply
```

Type `yes` when prompted to confirm.

### Step 5: Verify the Cluster

```bash
# Check if the cluster is running
kubectl cluster-info --context kind-devops-workshop

# List nodes
kubectl get nodes --context kind-devops-workshop

# Check cluster status
docker ps
```

You should see Docker containers running that represent your Kubernetes nodes!

## 🔍 Understanding the Configuration

### Kind Cluster Configuration

Our `kind-config.yaml` creates a cluster with:
- 1 Control plane node
- 2 Worker nodes
- Exposed ports for services
- Ingress controller support

### Terraform Resources

1. **kind_cluster**: Creates the Kubernetes cluster
2. **Local file**: Saves kubeconfig for easy access

## 🎯 Workshop Tasks

### Task 1.1: Basic Cluster Creation ✅
Follow the steps above to create your first Kind cluster with Terraform.

### Task 1.2: Explore the Cluster
```bash
# Get cluster information
kubectl cluster-info --context kind-devops-workshop

# List all namespaces
kubectl get namespaces --context kind-devops-workshop

# Check system pods
kubectl get pods -n kube-system --context kind-devops-workshop
```

### Task 1.3: Customize the Cluster
1. Edit `terraform.tfvars` to change the cluster name
2. Run `terraform plan` to see the changes
3. Run `terraform apply` to update the cluster

### Task 1.4: Understanding State
```bash
# View Terraform state
terraform show

# List resources in state
terraform state list
```

## 🧪 Validation Checklist

- [ ] Terraform initialization completed successfully
- [ ] Cluster created without errors
- [ ] kubectl can connect to the cluster
- [ ] All nodes are in "Ready" state
- [ ] System pods are running

## 🔧 Troubleshooting

### Issue: Docker not running
**Error:** `Cannot connect to the Docker daemon`
**Solution:** Start Docker Desktop or Docker daemon

### Issue: Port already in use
**Error:** `Port 80 is already in use`
**Solution:** Change the port mapping in `kind-config.yaml`

### Issue: kubectl context not found
**Error:** `context "kind-devops-workshop" not found`
**Solution:** Run `terraform apply` again to regenerate kubeconfig

## 🧹 Cleanup

When you're done with this task:
```bash
# Destroy the infrastructure
terraform destroy
```

**Note:** We'll keep the cluster running for the next task!

## 📚 Key Takeaways

1. **IaC Benefits**: Infrastructure is now version-controlled and reproducible
2. **Terraform Workflow**: init → plan → apply → destroy
3. **State Management**: Terraform tracks what it created
4. **Provider Ecosystem**: Terraform has providers for almost everything

## 🎯 Next Steps

Great job! You've successfully provisioned a Kubernetes cluster using Infrastructure as Code.

**Next Task:** [03-app-deployment](../03-app-deployment/README.md) - Deploy applications via Terraform

---

**💡 Pro Tip:** Always run `terraform plan` before `terraform apply` to understand what changes will be made!
