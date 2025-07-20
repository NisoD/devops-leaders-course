# DevOps Workshop - Prerequisites and Installation Guide

This guide helps participants prepare their environment for the DevOps Bootcamp workshop.

## 🖥️ System Requirements

- **Operating System**: macOS, Linux, or Windows 10/11 with WSL2
- **RAM**: Minimum 8GB, recommended 16GB
- **Disk Space**: At least 10GB free space
- **Internet Connection**: Required for downloading images and packages

## 🛠️ Required Software

### 1. Docker Desktop

**macOS:**
```bash
# Download from https://www.docker.com/products/docker-desktop
# Or install via Homebrew
brew install --cask docker
```

**Linux (Ubuntu/Debian):**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

**Windows:**
- Download Docker Desktop from https://www.docker.com/products/docker-desktop
- Ensure WSL2 is enabled

### 2. Terraform

**macOS:**
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

**Linux:**
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

**Windows:**
```powershell
# Using Chocolatey
choco install terraform

# Or download from https://www.terraform.io/downloads
```

### 3. kubectl

**macOS:**
```bash
brew install kubectl
```

**Linux:**
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

**Windows:**
```powershell
# Using Chocolatey
choco install kubernetes-cli

# Or download from https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
```

### 4. Kind (Kubernetes in Docker)

**macOS:**
```bash
brew install kind
```

**Linux:**
```bash
# Download latest binary
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

**Windows:**
```powershell
# Using Chocolatey
choco install kind

# Or download from https://kind.sigs.k8s.io/docs/user/quick-start/#installation
```

### 5. Helm (will be installed automatically if missing)

**macOS:**
```bash
brew install helm
```

**Linux:**
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

**Windows:**
```powershell
choco install kubernetes-helm
```

### 6. Git

**macOS:**
```bash
brew install git
```

**Linux:**
```bash
sudo apt update && sudo apt install git
```

**Windows:**
- Download from https://git-scm.com/download/win

## ✅ Verification Script

Save this script as `verify-setup.sh` and run it to check your installation:

```bash
#!/bin/bash
echo "🔍 Verifying DevOps Workshop Prerequisites"
echo "=========================================="

# Check Docker
if command -v docker &> /dev/null; then
    echo "✅ Docker: $(docker --version)"
    if docker info &> /dev/null; then
        echo "✅ Docker daemon is running"
    else
        echo "❌ Docker daemon is not running"
    fi
else
    echo "❌ Docker is not installed"
fi

# Check Terraform
if command -v terraform &> /dev/null; then
    echo "✅ Terraform: $(terraform version | head -n1)"
else
    echo "❌ Terraform is not installed"
fi

# Check kubectl
if command -v kubectl &> /dev/null; then
    echo "✅ kubectl: $(kubectl version --client --short 2>/dev/null)"
else
    echo "❌ kubectl is not installed"
fi

# Check Kind
if command -v kind &> /dev/null; then
    echo "✅ Kind: $(kind version)"
else
    echo "❌ Kind is not installed"
fi

# Check Helm
if command -v helm &> /dev/null; then
    echo "✅ Helm: $(helm version --short)"
else
    echo "⚠️ Helm is not installed (will be installed automatically)"
fi

# Check Git
if command -v git &> /dev/null; then
    echo "✅ Git: $(git --version)"
else
    echo "❌ Git is not installed"
fi

echo ""
echo "🚀 Setup verification complete!"
```

## 🐳 Docker Configuration

### Increase Docker Resources

For optimal performance, configure Docker with:

- **CPUs**: 4 cores (minimum 2)
- **Memory**: 6GB (minimum 4GB)  
- **Disk Space**: 20GB available

**Docker Desktop Settings:**
1. Open Docker Desktop
2. Go to Settings → Resources
3. Adjust CPU, Memory, and Disk limits
4. Click "Apply & Restart"

### Test Docker Installation

```bash
# Test Docker
docker run hello-world

# Test Docker Compose (included with Docker Desktop)
docker-compose --version
```

## 🔧 Troubleshooting

### Common Issues

#### Docker Permission Denied (Linux)
```bash
# Add user to docker group
sudo usermod -aG docker $USER
# Log out and back in, or run:
newgrp docker
```

#### kubectl: command not found
```bash
# Verify installation path
echo $PATH
# Add kubectl to PATH if needed
export PATH=$PATH:/usr/local/bin
```

#### Terraform: command not found
```bash
# Verify installation
which terraform
# If using package managers, ensure they're updated
```

### Performance Issues

If you experience slow performance:

1. **Increase Docker resources** (see above)
2. **Close unnecessary applications**
3. **Ensure SSD storage** for better I/O performance
4. **Check available RAM** (use `free -h` on Linux/macOS)

### Network Issues

If you have corporate firewall/proxy:

1. **Configure Docker proxy settings**
2. **Set HTTP/HTTPS proxy environment variables**
3. **Whitelist required domains**:
   - docker.io
   - registry-1.docker.io
   - releases.hashicorp.com
   - storage.googleapis.com (for kubectl)

## 📋 Pre-Workshop Checklist

Before the workshop starts, ensure:

- [ ] Docker Desktop is running
- [ ] All tools are installed and accessible
- [ ] Internet connection is stable
- [ ] At least 10GB free disk space
- [ ] Corporate firewall/proxy configured (if applicable)
- [ ] This repository is cloned locally

## 🎯 Quick Setup Script

For convenience, you can run our automated setup script:

```bash
# Clone the repository
git clone <repository-url>
cd "DevOps Bootcamp - IAC and Monitoring"

# Run the verification script
chmod +x scripts/verify-setup.sh
./scripts/verify-setup.sh

# If everything looks good, you're ready for the workshop!
```

## 📞 Getting Help

If you encounter issues during setup:

1. **Check the troubleshooting section above**
2. **Ask in the workshop chat/forum**
3. **Come early to the workshop** for setup assistance
4. **Contact the instructor** with specific error messages

## 🚀 You're Ready!

Once all tools are installed and verified, you're ready for the DevOps Bootcamp!

The workshop will guide you through:
- Infrastructure as Code with Terraform
- Kubernetes cluster management
- Application deployment
- Observability with Prometheus, Grafana, and Loki
- Creating monitoring dashboards

**See you in the workshop! 🎉**
