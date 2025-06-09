#!/bin/bash
set -e

echo "🔍 Running tests with pytest..."
pytest test_main.py

echo "🧼 Running lint check with flake8 (max-line-length=120)..."
flake8 main.py --max-line-length=120

echo "🎨 Running code formatting check with black (line length 120)..."
black main.py --check --line-length 120

echo "🔐 Scanning for secrets using detect-secrets..."
detect-secrets scan --baseline .secrets.baseline

echo "🛡️  Running security vulnerability scan with bandit..."
bandit -r main.py -ll -ii

echo "✅ All checks passed!"
