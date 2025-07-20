# Kind Installation Guide

Kind (Kubernetes in Docker) is a tool for running local Kubernetes clusters using Docker container "nodes". This guide covers installation across different platforms.

## 🐧 Linux Installation

### Method 1: Direct Binary Download
```bash
# Download the latest stable release
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64

# Make it executable
chmod +x ./kind

# Move to PATH
sudo mv ./kind /usr/local/bin/kind

# Verify installation
kind version
```

### Method 2: Using Package Managers

**Ubuntu/Debian (via apt):**
```bash
# Add the Kind repository
curl -fsSL https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64 -o kind
sudo install -o root -g root -m 0755 kind /usr/local/bin/kind
rm kind
```

## 🍎 macOS Installation

### Method 1: Homebrew (Recommended)
```bash
# Install via Homebrew
brew install kind

# Verify installation
kind version
```

### Method 2: Direct Binary Download
```bash
# Download for macOS
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-darwin-amd64

# For Apple Silicon Macs
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-darwin-arm64

# Make executable and move to PATH
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

## 🪟 Windows Installation

### Method 1: Chocolatey
```powershell
# Install via Chocolatey
choco install kind

# Verify installation
kind version
```

### Method 2: Direct Download
1. Download the Windows binary from: https://kind.sigs.k8s.io/dl/v0.20.0/kind-windows-amd64
2. Rename it to `kind.exe`
3. Add it to your PATH

### Method 3: PowerShell Script
```powershell
# Download and install
curl.exe -Lo kind-windows-amd64.exe https://kind.sigs.k8s.io/dl/v0.20.0/kind-windows-amd64
Move-Item .\kind-windows-amd64.exe c:\some-dir-in-your-PATH\kind.exe
```

## ✅ Verification

After installation, verify Kind works correctly:

```bash
# Check version
kind version

# Test cluster creation
kind create cluster --name test-cluster

# Verify cluster
kubectl cluster-info --context kind-test-cluster

# Clean up test cluster
kind delete cluster --name test-cluster
```

## 🐳 Docker Requirements

Kind requires Docker to be installed and running:

- **Docker Desktop** (macOS/Windows)
- **Docker Engine** (Linux)

**Minimum Docker version:** 17.09+

## 🔧 Configuration

### Default Cluster
```bash
# Create a simple cluster
kind create cluster

# This creates a cluster named "kind" by default
```

### Custom Configuration
```bash
# Create cluster with custom name
kind create cluster --name my-cluster

# Use custom configuration file
kind create cluster --config=kind-config.yaml
```

## 📚 Additional Resources

- [Kind Official Documentation](https://kind.sigs.k8s.io/)
- [Kind Quick Start Guide](https://kind.sigs.k8s.io/docs/user/quick-start/)
- [Kind Configuration Guide](https://kind.sigs.k8s.io/docs/user/configuration/)

## 🆘 Troubleshooting

### Common Issues

**Issue: Permission denied**
```bash
# Solution: Make sure Docker daemon is running and user has permissions
sudo usermod -aG docker $USER
# Log out and back in
```

**Issue: Port conflicts**
```bash
# Solution: Use different ports in kind config
# See kind-config.yaml in this workshop for examples
```

**Issue: Resource limits**
```bash
# Solution: Increase Docker resources
# Docker Desktop: Settings → Resources → Advanced
# Recommended: 4GB RAM, 2 CPUs minimum
```
