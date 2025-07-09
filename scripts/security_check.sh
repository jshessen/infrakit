#!/bin/bash

# Security check script for Docker compose project
# This script looks for actual sensitive data, not Docker secrets references

# Source docker-compose compatibility
source ./scripts/docker-compose-compat.sh

echo "🔍 Checking for potential security vulnerabilities..."
echo ""

# Check for actual passwords/secrets in files (not references to secrets)
echo "📋 Checking for hardcoded secrets..."
find . -type f \( -name "*.env" -o -name "*.yml" -o -name "*.yaml" -o -name "*.json" \) \
    -not -path "./secrets/*" \
    -not -path "./.git/*" \
    -not -path "./*/data/*" \
    -not -path "./*/config/db/*" \
    -exec grep -l -E "(password|secret|key|token|api).*(=|:).+[a-zA-Z0-9]{8,}" {} \; 2>/dev/null | \
    while read file; do
        # Show the lines but filter out legitimate references and comments
        suspicious_lines=$(grep -n -E "(password|secret|key|token|api).*(=|:).+[a-zA-Z0-9]{8,}" "$file" | \
        grep -v "file:///run/secrets/" | \
        grep -v "AUTHENTIK_SECRET_KEY: file://" | \
        grep -v "_FILE:" | \
        grep -v "^[[:space:]]*#" | \
        grep -v "example" | \
        grep -v "placeholder" | \
        grep -v "your_" | \
        head -5)
        
        if [ -n "$suspicious_lines" ]; then
            echo "⚠️  Found potential hardcoded secrets in: $file"
            echo "$suspicious_lines"
            echo ""
        fi
    done

# Check for .env files that might contain secrets
echo "📋 Checking for .env files with potential secrets..."
find . -name "*.env" -not -path "./.git/*" -not -path "./secrets/*" | while read file; do
    if grep -q -E "^[A-Z_]*PASSWORD=" "$file" 2>/dev/null; then
        echo "⚠️  Found password in .env file: $file"
    fi
    if grep -q -E "^[A-Z_]*SECRET=" "$file" 2>/dev/null; then
        echo "⚠️  Found secret in .env file: $file"
    fi
    if grep -q -E "^[A-Z_]*API_KEY=" "$file" 2>/dev/null; then
        echo "⚠️  Found API key in .env file: $file"
    fi
done

# Check for backup directories (but only ones that might be tracked)
echo "📋 Checking for backup directories in version control..."
find . -type d -name "*backup*" -o -name "*bkp*" -o -name "*old*" | \
    grep -v "./*/data/" | \
    while read dir; do
        echo "⚠️  Found backup directory that might be tracked: $dir"
    done

# Check for certificate files (but only in unexpected locations)
echo "📋 Checking for certificate files in version control..."
find . -name "*.pem" -o -name "*.key" -o -name "*.crt" -o -name "*.p12" -o -name "*.pfx" | \
    grep -v "./*/data/" | \
    grep -v "./*/config/db/" | \
    while read cert; do
        if [ -f "$cert" ]; then
            echo "⚠️  Found certificate file that might be tracked: $cert"
        fi
    done

# Check git status
echo "📋 Checking git status..."
if [ -d ".git" ]; then
    echo "Git tracked files that might contain secrets:"
    git ls-files | grep -E "\.(env|key|pem|crt|p12|pfx)$" | head -10
else
    echo "Not a git repository"
fi

echo ""
echo "✅ Security check complete!"
echo ""
echo "🔧 To fix issues:"
echo "1. Move any hardcoded secrets to files in ./secrets/ directory"
echo "2. Use Docker secrets: file:///run/secrets/secret_name"
echo "3. Remove or .gitignore any backup directories"
echo "4. Ensure certificates are in .gitignore"
