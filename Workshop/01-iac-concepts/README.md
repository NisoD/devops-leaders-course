# Infrastructure as Code (IaC) - Concepts and Overview

## 📖 Module Outline

This module covers the foundational concepts of Infrastructure as Code (IaC). By the end, you'll understand why IaC is essential in modern DevOps and be ready for hands-on practice.

### 📚 What You'll Learn
- ✅ IaC definition and core principles  
- ✅ Benefits over traditional infrastructure management
- ✅ Popular IaC tools comparison
- ✅ Terraform fundamentals and workflow
- ✅ Best practices for IaC implementation

### ⏱️ Time: 30 minutes (Reading + Discussion)

---

## 🎯 What is Infrastructure as Code?

**Infrastructure as Code (IaC)** is the practice of managing and provisioning computing infrastructure through machine-readable definition files, rather than through physical hardware configuration or interactive configuration tools.

### � Simple Analogy
Think of IaC like a recipe for cooking:
- **Traditional approach**: Each chef manually cooks, results vary
- **IaC approach**: Everyone follows the same recipe, consistent results

---

## 🔑 Core IaC Principles

### 1. **Declarative Configuration**
- ✅ **Define WHAT you want**, not HOW to get there
- ✅ Let the tool figure out the steps
- ✅ Example: "I want 3 web servers" vs "Create server 1, then server 2, then server 3"

### 2. **Version Control Integration**
- ✅ Infrastructure changes tracked in Git
- ✅ Peer review process for infrastructure changes  
- ✅ Complete rollback capabilities
- ✅ Audit trail of all changes

### 3. **Idempotency**
- ✅ Running the same configuration multiple times = same result
- ✅ Safe to re-run without unintended side effects
- ✅ Prevents configuration drift

### 4. **Immutable Infrastructure**
- ✅ Replace infrastructure rather than modifying it
- ✅ Eliminates configuration drift
- ✅ More predictable deployments
- ✅ Easier rollbacks

---

## 🛠️ IaC Tools Comparison

| Tool | Type | Best For | Pros | Cons |
|------|------|----------|------|------|
| **Terraform** | Declarative | Multi-cloud, comprehensive | Cloud-agnostic, large ecosystem | Learning curve |
| **CloudFormation** | Declarative | AWS-specific | Native AWS integration | AWS-only |
| **Ansible** | Imperative/Declarative | Configuration management | Simple syntax, agentless | Less declarative |
| **Pulumi** | Declarative | Programming languages | Familiar languages | Newer ecosystem |

**🎯 Workshop Choice: Terraform** - Best for learning multi-cloud IaC principles

---

## 🌟 Benefits of Infrastructure as Code

### ⚡ **Speed & Efficiency**
- **Before**: Hours/days to provision infrastructure manually
- **After**: Minutes to provision via code
- **Benefit**: Rapid environment setup and scaling

### 🎯 **Consistency & Reliability**  
- **Before**: "Works on my machine" syndrome
- **After**: Identical infrastructure across environments
- **Benefit**: Eliminates environment-specific bugs

### 💰 **Cost Management**
- **Before**: Forgotten resources running indefinitely
- **After**: Easy cleanup and resource optimization
- **Benefit**: Controlled cloud spending

### 🔒 **Risk Reduction**
- **Before**: Manual errors and configuration drift
- **After**: Tested, validated configurations
- **Benefit**: Fewer production incidents

### 📖 **Self-Documenting**
- **Before**: Tribal knowledge and outdated documentation  
- **After**: Code is the documentation
- **Benefit**: Clear understanding of infrastructure state

---

## 🏗️ Terraform Fundamentals

### 📁 Core Concepts

#### **1. Providers**
Terraform plugins that interact with APIs of cloud providers, SaaS providers, and other services.

```hcl
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}
```

#### **2. Resources**  
Infrastructure components like virtual machines, networks, or containers.

```hcl
resource "docker_image" "nginx" {
  name = "nginx:latest"
}

resource "docker_container" "web" {
  image = docker_image.nginx.image_id
  name  = "tutorial"
  
  ports {
    internal = 80
    external = 8000
  }
}
```

#### **3. Variables**
Make configurations reusable and environment-specific.

```hcl
variable "container_name" {
  description = "Name of the Docker container"
  type        = string
  default     = "my-app"
}

# Usage in resource
resource "docker_container" "app" {
  name = var.container_name
  # ... other configuration
}
```

#### **4. Outputs**
Return values from Terraform configurations.

```hcl
output "container_id" {
  description = "ID of the Docker container"
  value       = docker_container.web.id
}
```

### ⚙️ Terraform Workflow

```bash
# 1. WRITE - Author infrastructure as code
vim main.tf

# 2. INIT - Download required providers  
terraform init

# 3. PLAN - Preview changes before applying
terraform plan

# 4. APPLY - Create/update infrastructure
terraform apply

# 5. DESTROY - Clean up when done
terraform destroy
```

---

## 📝 IaC Best Practices

### 🗂️ **Project Structure**
```
terraform/
├── main.tf              # Main configuration
├── variables.tf         # Input variables  
├── outputs.tf          # Output values
├── versions.tf         # Provider versions
├── terraform.tfvars    # Variable values (don't commit secrets!)
└── modules/            # Reusable components
    └── app/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

### 🔐 **Security & State Management**
- ✅ Use remote state storage (S3, GCS, etc.)
- ✅ Enable state locking to prevent conflicts
- ✅ **Never commit** state files or secrets to Git
- ✅ Use variables for sensitive data
- ✅ Regular security scans of configurations

### 🧪 **Testing & Validation**
- ✅ Always run `terraform validate` before committing
- ✅ Use `terraform plan` before applying changes
- ✅ Implement automated testing (Terratest, etc.)
- ✅ Peer review all infrastructure changes

---

## 🎯 Workshop Context: What We'll Build

In the upcoming tasks, we'll use Terraform to create:

### Task 1: Kubernetes Cluster
- ✅ Kind cluster (Kubernetes in Docker)
- ✅ Multiple worker nodes
- ✅ Ingress controller setup

### Task 2: Application Deployment  
- ✅ Docker image builds
- ✅ Kubernetes deployments
- ✅ Services and ingress

### Task 3: Monitoring Infrastructure
- ✅ Prometheus for metrics
- ✅ Grafana for visualization
- ✅ Loki for log aggregation

**🎯 Real-world Impact**: This mirrors production infrastructure patterns where infrastructure and applications are managed as code.

---

## 🚀 Ready for Hands-On Practice?

Great! You now understand the core concepts of Infrastructure as Code. Time to put theory into practice.

**Next Step:** [📁 Task 1: Provision Kubernetes cluster](../02-terraform-k8s/README.md)

---

## 📚 Further Reading (Extensions)

### Advanced IaC Concepts
- **State Management**: Remote backends, state locking, workspaces
- **Module Development**: Creating reusable Terraform modules  
- **Testing Strategies**: Unit testing infrastructure code
- **CI/CD Integration**: Automated infrastructure pipelines
- **Multi-Environment**: Dev/Staging/Prod pattern management

### Related Technologies
- **GitOps**: Infrastructure deployment via Git workflows
- **Policy as Code**: OPA/Sentinel for compliance automation
- **Configuration Management**: Ansible, Chef, Puppet integration
- **Cloud-Native IaC**: Kubernetes Operators, Crossplane

### Resources
- [Terraform Best Practices Guide](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Google Cloud Architecture Center](https://cloud.google.com/architecture)

---

**💡 Key Takeaway**: Infrastructure as Code is not just about tools - it's about treating infrastructure with the same discipline and practices as application code!

#### **Outputs**
```hcl
output "container_id" {
  description = "ID of the Docker container"
  value       = docker_container.web.id
}
```

### **Terraform Workflow**

1. **Write** - Author infrastructure as code
2. **Plan** - Preview changes before applying
3. **Apply** - Provision infrastructure
4. **Destroy** - Clean up when done

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy
```

## 🎯 Workshop Context

In this workshop, we'll use Terraform to:

1. **Provision a Kubernetes cluster** using Kind (Kubernetes in Docker)
2. **Deploy applications** to the cluster
3. **Set up monitoring infrastructure** (Prometheus, Grafana, Loki)

This demonstrates real-world IaC practices where infrastructure and applications are managed as code.

## 📝 Best Practices

### **Project Structure**
```
terraform/
├── main.tf              # Main configuration
├── variables.tf         # Input variables
├── outputs.tf          # Output values
├── versions.tf         # Provider versions
├── terraform.tfvars    # Variable values
└── modules/            # Reusable modules
    └── app/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

### **State Management**
- Use remote state storage (S3, GCS, etc.)
- Enable state locking
- Never commit state files to Git

### **Security**
- Use variables for sensitive data
- Leverage cloud provider IAM
- Regular security scans

### **Testing**
- Validate configurations with `terraform validate`
- Use `terraform plan` before applying
- Implement automated testing

## 🚀 Ready to Start?

Now that you understand the concepts, let's move to hands-on practice:

**Next Step:** [02-terraform-k8s](../02-terraform-k8s/README.md) - Provision Kubernetes cluster with Terraform

---

**💡 Pro Tip:** Infrastructure as Code is not just about tools - it's about treating infrastructure with the same discipline as application code!
