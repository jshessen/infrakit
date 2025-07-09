#!/bin/bash

# InfraKit Setup Script
# Creates .env files from .env.example templates

echo "🚀 InfraKit Setup Script"
echo "========================="
echo ""
echo "This script will help you create .env files from the .env.example templates."
echo ""

# Function to copy .env.example to .env if it doesn't exist
setup_env_file() {
    local dir="$1"
    local service="$2"
    
    if [ -f "$dir/.env.example" ]; then
        if [ ! -f "$dir/.env" ]; then
            echo "✅ Creating $dir/.env from .env.example"
            cp "$dir/.env.example" "$dir/.env"
        else
            echo "ℹ️  $dir/.env already exists (skipping)"
        fi
    else
        echo "⚠️  No .env.example found in $dir"
    fi
}

# Main .env file
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        echo "✅ Creating main .env from .env.example"
        cp ".env.example" ".env"
    else
        echo "⚠️  No main .env.example found"
    fi
else
    echo "ℹ️  Main .env already exists (skipping)"
fi

echo ""
echo "📋 Setting up service .env files..."

# Setup .env files for each service
setup_env_file "authentik" "Authentik Identity Provider"
setup_env_file "caddy" "Caddy Proxy Server"
setup_env_file "dozzle" "Dozzle Log Viewer"
setup_env_file "glances" "Glances System Monitor"
setup_env_file "guacamole" "Guacamole Remote Desktop"
setup_env_file "portainer" "Portainer Container Management"
setup_env_file "socket-proxy" "Socket Proxy Security"
setup_env_file "watchtower" "Watchtower Auto-Updates"

echo ""
echo "🔐 Next Steps:"
echo "1. Edit the .env files to customize ports and settings"
echo "2. Follow SECRETS_SETUP.md to create required secrets"
echo "3. Run './scripts/security_check.sh' to verify your setup"
echo "4. Start services with 'make up'"
echo ""
echo "✅ Environment setup complete!"
