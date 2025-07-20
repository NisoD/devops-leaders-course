# Task 1: Provision Kubernetes Cluster with Terraform

## 📖 Task Outline  

This hands-on task teaches you to provision a Kubernetes cluster using Terraform and the Kind provider. You'll learn infrastructure provisioning fundamentals and Terraform state management.

### 🎯 **Learning Objectives**
- ✅ Set up Terraform providers and configurations
- ✅ Provision a Kind Kubernetes cluster via code
- ✅ Understand Terraform state management
- ✅ Work with Kubernetes contexts and kubeconfig

### ⏱️ **Time**: 30 minutes
### 🛠️ **Prerequisites**: Docker, Terraform, kubectl, Kind installed

---

## 🚀 Step-by-Step Execution

### Step 1: Environment Verification ✅

**First, verify your environment is ready:**

```bash
# Run from the workshop root directory
./scripts/verify-setup.sh
```

**Expected output should show ✅ for all tools.**

### Step 2: Navigate and Explore 📁

```bash
# Navigate to this task directory
cd Workshop/02-terraform-k8s

# Explore the file structure
ls -la
```

**📁 Files Overview:**
```
02-terraform-k8s/
├── README.md                  # This guide
├── main.tf                   # Main Terraform resources
├── variables.tf              # Input variables
├── outputs.tf               # Output values  
├── versions.tf              # Provider requirements
├── terraform.tfvars.example # Example configuration
└── devops-workshop-config   # Kind cluster configuration
```

### Step 3: Initialize Terraform �

```bash
# Download required providers
terraform init
```

**✅ Expected output:**
```
Initializing the backend...
Initializing provider plugins...
- Finding tehcyx/kind versions matching "~> 0.4"...
- Installing tehcyx/kind v0.4.0...
Terraform has been successfully initialized!
```

### Step 4: Configure Variables ⚙️

```bash
# Create your variables file
cp terraform.tfvars.example terraform.tfvars

# (Optional) Edit cluster settings
vim terraform.tfvars
```

### Step 5: Plan Infrastructure 📋

```bash
# Preview what will be created
terraform plan
```

**💡 This shows exactly what infrastructure Terraform will create before applying.**

### Step 6: Apply Configuration 🚀

```bash
# Create the infrastructure
terraform apply
```

**Type `yes` when prompted to confirm.**

**⏱️ Expected time: 2-3 minutes for cluster creation**

### Step 7: Verify Cluster ✅

```bash
# Check cluster information
kubectl cluster-info --context kind-devops-workshop

# List cluster nodes
kubectl get nodes --context kind-devops-workshop

# Verify Docker containers (Kind runs K8s in containers)
docker ps
```

**✅ Success indicators:**
- Cluster info shows master and DNS endpoints
- Nodes show "Ready" status
- Docker containers running with "devops-workshop" in names

---

## 🔍 Understanding the Configuration

### 🐳 **Kind Cluster Configuration**

Our cluster includes:
- **1 Control plane node** (master)
- **2 Worker nodes** (for realistic multi-node setup)
- **Exposed ports** for accessing services
- **Ingress controller support** (for web traffic)

### ⚙️ **Terraform Resources**

**Key resources created:**

1. **`kind_cluster`**: The Kubernetes cluster itself
   ```hcl
   resource "kind_cluster" "main" {
     name           = var.cluster_name
     config         = file("${path.module}/devops-workshop-config")
     wait_for_ready = true
   }
   ```

2. **`local_file`**: Saves kubeconfig for easy access
   ```hcl 
   resource "local_file" "kubeconfig" {
     content  = kind_cluster.main.kubeconfig
     filename = "${path.module}/kubeconfig"
   }
   ```

### 🗂️ **State Management**

Terraform creates a `terraform.tfstate` file that:
- ✅ Tracks what resources were created
- ✅ Maps configuration to real infrastructure
- ✅ Enables updates and destruction

---

## 🎯 Workshop Tasks & Validation

### Task 1.1: Basic Cluster Creation ✅
**Objective**: Successfully create your first Kind cluster

**Validation:**
```bash
# All commands should work without errors
kubectl cluster-info --context kind-devops-workshop
kubectl get nodes --context kind-devops-workshop
```

### Task 1.2: Explore the Cluster 🔍
**Objective**: Understand what was created

```bash
# Get cluster information
kubectl cluster-info --context kind-devops-workshop

# List all namespaces (Kubernetes organization units)
kubectl get namespaces --context kind-devops-workshop

# Check system pods (Kubernetes core components)
kubectl get pods -n kube-system --context kind-devops-workshop
```

### Task 1.3: Modify Configuration 🔧
**Objective**: Practice infrastructure changes

```bash
# 1. Edit cluster name in terraform.tfvars
vim terraform.tfvars

# 2. Preview changes
terraform plan

# 3. Apply changes (this will recreate the cluster)
terraform apply
```

**⚠️ Note**: Changing cluster name recreates the entire cluster!

### Task 1.4: Understand State 📊
**Objective**: Learn about Terraform state management

```bash
# View current state
terraform show

# List managed resources
terraform state list

# Get specific resource details
terraform state show kind_cluster.main
```

---

## ✅ Validation Checklist

Before proceeding to the next task, confirm:

- [ ] `terraform init` completed successfully
- [ ] Cluster created without errors
- [ ] `kubectl cluster-info` shows valid endpoints
- [ ] All nodes show "Ready" state
- [ ] System pods are running in kube-system namespace
- [ ] Docker containers visible with `docker ps`

---

## 🔧 Troubleshooting

### ❌ **Issue**: Docker not running
**Error**: `Cannot connect to the Docker daemon`  
**Solution**: 
```bash
# macOS: Start Docker Desktop
# Linux: Start Docker daemon
sudo systemctl start docker
```

### ❌ **Issue**: Port conflicts
**Error**: `Port 80 is already in use`
**Solution**: Edit `devops-workshop-config` to use different ports

### ❌ **Issue**: kubectl context not found  
**Error**: `context "kind-devops-workshop" not found`
**Solution**: 
```bash
# Re-run terraform to regenerate kubeconfig
terraform apply
```

### ❌ **Issue**: Terraform provider download fails
**Error**: `Error installing provider`
**Solution**: Check internet connection and retry `terraform init`

---

## 🧹 Cleanup (Don't Do This Yet!)

**⚠️ Keep your cluster running for the next tasks!**

When you're completely done with the workshop:
```bash
# This will destroy all created infrastructure
terraform destroy
```

---

## 📚 Key Takeaways

### ✅ **Infrastructure as Code Benefits**
- **Reproducible**: Same cluster every time
- **Version Controlled**: Changes tracked in Git
- **Auditable**: Clear record of what exists

### ✅ **Terraform Workflow Mastered**
- **`init`**: Download providers and modules
- **`plan`**: Preview changes before applying  
- **`apply`**: Create/update infrastructure
- **`destroy`**: Clean up resources

### ✅ **State Management Understood**  
- State file tracks real infrastructure
- Enables updates and dependency management
- Should be stored remotely in production

---

## 🎯 Next Steps

Excellent work! You've successfully provisioned a Kubernetes cluster using Infrastructure as Code. Your cluster is now ready for application deployment.

**➡️ Continue to**: [Task 2: Deploy Application via Terraform](../03-app-deployment/README.md)

---

## 📚 Further Reading (Extensions)

### Advanced Terraform Concepts
- **Remote State**: Using S3, GCS, or Terraform Cloud for state storage
- **Workspaces**: Managing multiple environments (dev/staging/prod)
- **Modules**: Creating reusable infrastructure components
- **Import**: Bringing existing infrastructure under Terraform management

### Kind & Kubernetes
- **Kind Configuration**: Advanced node and networking options
- **Cluster API**: Production-grade cluster management
- **kubeadm**: Understanding Kubernetes bootstrap process
- **Multi-cluster**: Managing multiple Kubernetes environments

### Production Considerations
- **Security**: RBAC, network policies, pod security standards
- **High Availability**: Multi-master setups, etcd clustering
- **Monitoring**: Cluster health and resource utilization
- **Backup & Recovery**: etcd backups, disaster recovery plans

---

**💡 Pro Tip**: Always run `terraform plan` before `terraform apply` to understand exactly what changes will be made to your infrastructure!

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
