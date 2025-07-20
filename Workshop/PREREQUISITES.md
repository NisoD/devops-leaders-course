# DevOps Workshop - Prerequisites and Installation Guide

## 📖 Overview

This guide ensures your environment is ready for the DevOps Bootcamp workshop. Follow the installation steps for your operating system to set up all required tools.

### ⚡ Quick Verification
After installation, run this command to check everything is working:
```bash
./scripts/verify-setup.sh
```

---

## � System Requirements

### **Minimum Requirements**
- **Operating System**: macOS 10.15+, Ubuntu 18.04+, Windows 10/11 with WSL2
- **RAM**: 8GB minimum, **16GB recommended**
- **Disk Space**: 10GB free space for images and data
- **Internet Connection**: Required for downloading images, charts, and packages

### **Performance Notes**
- More RAM = smoother workshop experience
- SSD storage recommended for faster container operations
- Stable internet connection prevents workshop interruptions

---

## 🛠️ Required Software Installation

### 1. **Docker Desktop** 🐳

Docker runs our containers and Kubernetes clusters.

#### macOS Installation
```bash
# Option 1: Download from website
# Visit: https://www.docker.com/products/docker-desktop

# Option 2: Install via Homebrew (recommended)
brew install --cask docker

# Start Docker Desktop from Applications
open -a Docker
```

#### Linux (Ubuntu/Debian) Installation  
```bash
# Install Docker Engine
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add your user to docker group (to run without sudo)
sudo usermod -aG docker $USER

# Restart session to apply group changes
newgrp docker

# Enable Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Test installation
docker run hello-world
```

#### Windows Installation
1. **Enable WSL2** (Windows Subsystem for Linux)
2. **Download Docker Desktop** from https://www.docker.com/products/docker-desktop
3. **During installation**, ensure "Use WSL 2 instead of Hyper-V" is selected
4. **Restart** Windows after installation

**✅ Verification:**
```bash
docker --version
docker run hello-world
```

### 2. **Terraform** 🏗️

Infrastructure as Code tool for provisioning resources.

#### macOS Installation
```bash
# Install via Homebrew (recommended)
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

#### Linux Installation
```bash
# Ubuntu/Debian
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

#### Windows Installation
```powershell
# Install via Chocolatey
choco install terraform

# Or download binary from: https://www.terraform.io/downloads
```

**✅ Verification:**
```bash
terraform version
# Should show: Terraform v1.x.x
```
# Using Chocolatey
choco install terraform

# Or download from https://www.terraform.io/downloads
```

### 3. **kubectl** ⚙️

Kubernetes command-line tool for cluster management.

#### macOS Installation
```bash
# Install via Homebrew (recommended)
brew install kubectl
```

#### Linux Installation
```bash
# Download latest stable release
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Install kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Clean up downloaded file
rm kubectl
```

#### Windows Installation
```powershell
# Install via Chocolatey
choco install kubernetes-cli

# Or download from: https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
```

**✅ Verification:**
```bash
kubectl version --client
# Should show client version information
```

### 4. **Kind** 🐳

Kubernetes in Docker - runs Kubernetes clusters using Docker containers.

#### macOS Installation
```bash
# Install via Homebrew (recommended)
brew install kind
```

#### Linux Installation
```bash
# Download latest binary (replace with current version)
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

#### Windows Installation
```powershell
# Install via Chocolatey
choco install kind

# Or download from: https://kind.sigs.k8s.io/docs/user/quick-start/#installation
```

**✅ Verification:**
```bash
kind version
# Should show kind version information
```

### 5. **Helm** ⎈ (Optional - Auto-installed)

Kubernetes package manager. The workshop will install this automatically if missing.

#### macOS Installation  
```bash
# Install via Homebrew (recommended)
brew install helm
```

#### Linux Installation
```bash
# Official installation script
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

#### Windows Installation
```powershell
# Install via Chocolatey
choco install kubernetes-helm
```

**✅ Verification:**
```bash
helm version
# Should show helm version information
```

### 6. **Git** 📋

Version control system (usually pre-installed).

#### macOS Installation
```bash
# Install via Homebrew if not present
brew install git
```

#### Linux Installation
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install git

# CentOS/RHEL
sudo yum install git
```

#### Windows Installation
- Download from https://git-scm.com/download/win
- Use Git Bash as your terminal for workshop commands

**✅ Verification:**
```bash
git --version
# Should show git version information
```

---

## ✅ Complete Verification

### Automated Check
The workshop includes a verification script that checks all requirements:

```bash
# From the workshop root directory
./scripts/verify-setup.sh
```

**Expected output should show ✅ for all required tools.**

### Manual Verification
You can also test each tool individually:

```bash
# Test all tools are accessible
docker --version && echo "✅ Docker"
terraform version && echo "✅ Terraform"  
kubectl version --client && echo "✅ kubectl"
kind version && echo "✅ Kind"
helm version && echo "✅ Helm"
git --version && echo "✅ Git"

# Test Docker daemon is running
docker run hello-world && echo "✅ Docker Daemon"
```

---

## ⚙️ Docker Configuration & Optimization

### Resource Allocation
For smooth workshop experience, configure Docker with adequate resources:

#### Docker Desktop Settings
1. **Open Docker Desktop** → Settings/Preferences → Resources
2. **Recommended Settings**:
   - **CPUs**: 4 cores (minimum 2)
   - **Memory**: 6GB (minimum 4GB)  
   - **Disk Space**: 20GB available space
   - **Swap**: 1GB
3. **Apply & Restart** Docker Desktop

#### Verify Resource Allocation
```bash
# Check available resources
docker system info | grep -E "CPUs|Total Memory"
```

### Docker Performance Testing
```bash
# Test Docker performance
docker run --rm -it alpine:latest sh -c "echo 'Docker is working!'"

# Test resource-intensive operation
docker run --rm -it nginx:alpine echo "Nginx image pull successful"
```

---

## 🔧 Common Troubleshooting

### Docker Issues

#### **Issue**: Permission denied (Linux/macOS)
**Error**: `permission denied while trying to connect to Docker daemon`
**Solution**:
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Apply group changes (logout/login or use newgrp)
newgrp docker

# Test access
docker run hello-world
```

#### **Issue**: Docker daemon not running
**Error**: `Cannot connect to the Docker daemon`
**Solution**:
- **macOS**: Start Docker Desktop application
- **Linux**: `sudo systemctl start docker`
- **Windows**: Start Docker Desktop

#### **Issue**: Port conflicts
**Error**: `Port already in use`
**Solution**: Stop conflicting services or change ports in configuration

### Terraform Issues

#### **Issue**: Command not found
**Error**: `terraform: command not found`
**Solution**:
```bash
# Check if installed
which terraform

# Add to PATH if needed (replace with actual path)
export PATH=$PATH:/usr/local/bin

# Make permanent (add to ~/.bashrc or ~/.zshrc)
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
```

### kubectl Issues

#### **Issue**: Unable to connect to cluster
**Error**: `The connection to the server localhost:8080 was refused`
**Solution**: This is normal before creating a cluster - we'll create one in the workshop

#### **Issue**: Context not found  
**Error**: `context "kind-devops-workshop" not found`
**Solution**: This context is created during the workshop when we provision the cluster

### Kind Issues

#### **Issue**: Docker not accessible
**Error**: `failed to create cluster: failed to create nodes`
**Solution**: Ensure Docker daemon is running and accessible

---

## 🎯 Workshop Preparation Checklist

Before starting the workshop, ensure:

- [ ] All required software installed and verified
- [ ] Docker Desktop running with adequate resources  
- [ ] Internet connection stable for downloads
- [ ] Terminal/command prompt accessible
- [ ] Workshop materials downloaded/cloned
- [ ] Backup plan for network issues (mobile hotspot, etc.)

---

## 🆘 Getting Help

### Pre-Workshop Support
If you encounter issues during setup:

1. **Check troubleshooting section** above
2. **Run the verification script**: `./scripts/verify-setup.sh`  
3. **Search common issues** in the workshop repository
4. **Ask for help** in the workshop chat/forum
5. **Arrive early** to workshop for setup assistance

### During Workshop  
- Raise your hand for immediate assistance
- Use workshop chat for quick questions
- Help your neighbors - peer support is encouraged!

### Resources
- [Docker Documentation](https://docs.docker.com/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs)
- [Kind Documentation](https://kind.sigs.k8s.io/)

---

**✅ Ready to Start?** Once all tools show ✅ in verification, you're ready for the workshop!

**➡️ Next**: Return to [Workshop README](README.md) to begin the learning journey.

---

## 🔄 Alternative Installation Methods

### Using Package Managers

#### **macOS with Homebrew** (Recommended)
```bash
# Install all tools at once
brew install --cask docker
brew install terraform kubectl helm kind git

# Start Docker Desktop
open -a Docker
```

#### **Linux with Snap** (Alternative)
```bash
# Install available tools via snap
sudo snap install kubectl --classic
sudo snap install helm --classic
sudo snap install terraform

# Docker and Kind need manual installation
```

#### **Windows with Chocolatey** (Alternative)
```powershell
# Install all tools at once  
choco install docker-desktop terraform kubernetes-cli kubernetes-helm kind git

# Restart terminal after installation
```

### Containerized Workshop Environment

If local installation is problematic, consider:
- **GitHub Codespaces** - Cloud development environment
- **Docker-in-Docker** - Run entire workshop in container
- **VM with pre-configured tools** - VirtualBox/VMware setup

**Note**: These alternatives may require additional setup and aren't covered in the main workshop.

---

**💡 Pro Tip**: Use package managers when possible - they handle dependencies and PATH configuration automatically!
