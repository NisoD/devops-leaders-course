#!/bin/bash
set -e

echo "🔍 Running all code quality checks for main.py..."

# 1. Run Unit Tests
echo "🧪 Running unit tests with pytest..."
pytest main.py

# 2. Code Format Check
echo "🧼 Checking formatting with black..."
black --check main.py

echo "📦 Checking import order with isort..."
isort main.py --check-only

# 3. Linting
echo "🚨 Checking code quality with flake8..."
flake8 main.py --max-line-length=120

# 4. Secret Scanning
echo "🕵️ Checking for secrets with detect-secrets..."
# Initialize baseline if needed (use --baseline .secrets.baseline in CI)
detect-secrets scan --all-files > /tmp/secrets_report.json
if grep -q '"type":' /tmp/secrets_report.json; then
    echo "❌ Potential secrets detected!"
    cat /tmp/secrets_report.json
    exit 1
else
    echo "✅ No secrets detected."
fi

# 5. Code Vulnerabilities
echo "🔐 Scanning for code security issues with bandit..."
bandit -q -r main.py

# 6. Dependency Vulnerabilities
echo "📦 Checking for vulnerable dependencies with pip-audit..."
pip-audit > /tmp/pip_audit_report.txt || {
    cat /tmp/pip_audit_report.txt
    echo "❌ Vulnerabilities found in dependencies."
    exit 1
}

echo "✅ All checks passed successfully!"

