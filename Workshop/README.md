# DevOps Bootcamp: Infrastructure as Code (IaC) and Observability

Welcome to the comprehensive 4-hour workshop on Infrastructure as Code and Observability! This hands-on session will teach you how to provision infrastructure using Terraform and implement a complete observability stack.

## 📖 Workshop Outline

### 📋 Prerequisites Check
Before starting, verify your environment is ready:
```bash
./scripts/verify-setup.sh
```

### 🎯 Learning Path Overview
This workshop follows a structured path where each module builds upon the previous one:

```
Prerequisites → IaC Concepts → Terraform + K8s → App Deployment → Monitoring → Dashboards
```

### 📅 Schedule (4.25 hours + 30min break)

**Part 1: Infrastructure as Code (1.75 hours)**
- 📚 [IaC Overview and Concepts](01-iac-concepts/README.md) (30 min)
- 🛠️ [Task 1: Provision Kubernetes cluster](02-terraform-k8s/README.md) (30 min)
- 🚀 [Task 2: Deploy Application](03-app-deployment/README.md) (35 min)

**Break (30 minutes)**

**Part 2: Observability and Monitoring (2 hours)**
- 📚 [Observability Concepts Overview](04-observability-concepts/README.md) (30 min)
- 🛠️ [Task 3: Deploy Monitoring Stack](05-monitoring-stack/README.md) (45 min)
- 📊 [Task 4: Create Grafana Dashboards](06-grafana-dashboards/README.md) (45 min)

---

## ⚡ Quick Start Guide

### Step 1: Environment Setup
1. **Prerequisites Check**: Run `./scripts/verify-setup.sh`
2. **Missing Tools?** See [PREREQUISITES.md](PREREQUISITES.md) for installation guides
3. **Kind Installation**: See [KIND_INSTALLATION.md](KIND_INSTALLATION.md) if needed

### Step 2: Workshop Execution
1. **Start with Theory**: Read [01-iac-concepts/README.md](01-iac-concepts/README.md)
2. **Follow Hands-on Tasks**: Complete Tasks 1-4 in sequence
3. **Use Helper Scripts**: Located in `scripts/` directory for setup/cleanup

### Step 3: Validation
Each task includes validation steps to confirm successful completion.

---

## 🎯 Learning Objectives

By the end of this workshop, you will be able to:
- ✅ Understand IaC principles and best practices
- ✅ Provision Kubernetes clusters using Terraform
- ✅ Deploy applications using Infrastructure as Code
- ✅ Implement comprehensive observability with Prometheus, Grafana, and Loki
- ✅ Create meaningful dashboards and alerts
- ✅ Add structured logging to applications

---

## � Workshop Structure

```
Workshop/
├── 01-iac-concepts/           # 📚 Theory: IaC principles and concepts
├── 02-terraform-k8s/          # 🛠️ Task 1: Provision K8s cluster
├── 03-app-deployment/         # 🚀 Task 2: Deploy application
├── 04-observability-concepts/ # 📚 Theory: Observability principles
├── 05-monitoring-stack/       # 🛠️ Task 3: Deploy monitoring stack
├── 06-grafana-dashboards/     # 📊 Task 4: Create dashboards
├── scripts/                   # 🔧 Helper scripts (setup, cleanup, validation)
├── PREREQUISITES.md           # 📋 Installation requirements
├── CONTRIBUTING.md            # 🤝 Contribution guidelines
└── KIND_INSTALLATION.md       # 🐳 Kind-specific setup
```

---

## �️ Prerequisites

### Required Knowledge
- DevOps Basics
- Linux and CI/CD fundamentals
- Container concepts
- Kubernetes basics

### Required Software
- ✅ Docker installed and running
- ✅ kubectl installed
- ✅ Kind installed (Kubernetes in Docker)
- ✅ Terraform installed (>= 1.0)
- ✅ Git basics

**Need help installing?** See [PREREQUISITES.md](PREREQUISITES.md) for detailed installation guides.

---

## 📚 Further Reading & Extensions

### Core Documentation
- [Terraform Documentation](https://www.terraform.io/docs) - Infrastructure as Code
- [Kubernetes Documentation](https://kubernetes.io/docs) - Container orchestration
- [Prometheus Documentation](https://prometheus.io/docs) - Metrics collection
- [Grafana Documentation](https://grafana.com/docs) - Observability dashboards

### Advanced Topics (Not Covered in Workshop)
- Multi-cloud Terraform deployments
- GitOps with ArgoCD/Flux
- Advanced Kubernetes security
- Service mesh observability
- MLOps monitoring patterns

### Community & Support
- [Workshop Issues](https://github.com/your-repo/issues) - Report problems
- [Discussions](https://github.com/your-repo/discussions) - Ask questions
- [Contributing Guide](CONTRIBUTING.md) - Help improve the workshop

---

**Ready to start? Begin with [01-iac-concepts/README.md](01-iac-concepts/README.md)** 🚀
