# DevOps Bootcamp: Infrastructure as Code (IaC) and Observability

Welcome to the comprehensive 4-hour workshop on Infrastructure as Code and Observability! This hands-on session will teach you how to provision infrastructure using Terraform and implement a complete observability stack.

## 🎯 Learning Objectives

By the end of this workshop, you will be able to:
- Understand IaC principles and best practices
- Provision Kubernetes clusters using Terraform
- Deploy applications using Infrastructure as Code
- Implement comprehensive observability with Prometheus, Grafana, and Loki
- Create meaningful dashboards and alerts
- Add structured logging to applications

## 📋 Prerequisites

- Completion of previous sessions:
  - DevOps Basics
  - Linux and CI/CD in Real World
  - Containers
  - Kubernetes
- Docker installed and running
- kubectl installed
- Kind installed (Kubernetes in Docker)
- Terraform installed (>= 1.0)
- Git basics

**Quick Setup Check:**
```bash
./scripts/verify-setup.sh
```

**Need to install Kind?** See [KIND_INSTALLATION.md](KIND_INSTALLATION.md) for detailed instructions.

## 🕐 Schedule (4.25 hours + 30min break)

### Part 1: Infrastructure as Code (1.75 hours)
- IaC Overview and Concepts (30 min)
- Task 1: Provision Kubernetes cluster with Kind via Terraform (30 min)
- Task 2: Build, Deploy Application via Terraform (35 min)

### Break (30 minutes)

### Part 2: Observability and Monitoring (2 hours)
- Observability Concepts Overview (30 min)
- Task 3: Deploy Monitoring Stack (Prometheus, Grafana, Loki, Alloy) (45 min)
- Task 4: Create Grafana Dashboards and Visualizations (45 min)

## 🗂️ Workshop Structure

```
├── 01-iac-concepts/           # IaC theory and examples
├── 02-terraform-k8s/          # Terraform configurations for K8s
├── 03-app-deployment/         # Enhanced application deployment with logging
├── 04-observability-concepts/ # Observability theory
├── 05-monitoring-stack/       # Prometheus, Grafana, Loki setup
├── 06-grafana-dashboards/     # Dashboard configurations & automation
└── scripts/                   # Helper scripts
```

## 🚀 Getting Started

1. Clone this repository
2. Follow the README files in each directory in order
3. Complete the tasks step by step
4. Ask questions during the workshop!

## 📚 Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs)
- [Prometheus Documentation](https://prometheus.io/docs)
- [Grafana Documentation](https://grafana.com/docs)

---

**Happy Learning! 🎉**
