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
