# Infrastructure as Code (IaC) - Concepts and Overview

## 🎯 What is Infrastructure as Code?

Infrastructure as Code (IaC) is the practice of managing and provisioning computing infrastructure through machine-readable definition files, rather than through physical hardware configuration or interactive configuration tools.

## 🔑 Key Principles

### 1. **Declarative Configuration**
- Define the desired state of your infrastructure
- Let the tool figure out how to achieve that state
- Example: "I want 3 web servers" vs "Create server 1, then server 2, then server 3"

### 2. **Version Control**
- Infrastructure changes are tracked in Git
- Peer review process for infrastructure changes
- Rollback capabilities

### 3. **Idempotency**
- Running the same configuration multiple times produces the same result
- Safe to re-run without side effects

### 4. **Immutable Infrastructure**
- Replace infrastructure rather than modifying it
- Reduces configuration drift
- More predictable deployments

## 🛠️ Popular IaC Tools

| Tool | Type | Best For |
|------|------|----------|
| **Terraform** | Declarative | Multi-cloud, comprehensive |
| **CloudFormation** | Declarative | AWS-specific |
| **Ansible** | Imperative/Declarative | Configuration management |
| **Pulumi** | Declarative | Using familiar programming languages |

## 🌟 Benefits of IaC

### **Consistency**
- Same infrastructure across environments
- Eliminates "works on my machine" issues

### **Speed**
- Rapid provisioning and deployment
- Automated infrastructure setup

### **Reliability**
- Reduced human error
- Tested and validated configurations

### **Cost Management**
- Resource optimization
- Easy cleanup and deprovisioning

### **Documentation**
- Infrastructure is self-documenting
- Clear understanding of what exists

## 🏗️ Terraform Basics

### **Core Concepts**

#### **Providers**
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

#### **Resources**
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

#### **Variables**
```hcl
variable "container_name" {
  description = "Name of the Docker container"
  type        = string
  default     = "my-app"
}
```

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
