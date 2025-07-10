#!/bin/bash

# InfraKit Installer
# Supports multiple deployment types

set -e

REPO_URL="https://github.com/jshessen/infrakit.git"
DEPLOYMENT_TYPE=""
INSTALL_DIR=""

show_help() {
    echo "InfraKit Installer"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -t, --type TYPE     Deployment type (full|edge|monitor)"
    echo "  -d, --dir DIR       Installation directory (default: ./infrakit)"
    echo "  -h, --help          Show this help"
    echo ""
    echo "Deployment Types:"
    echo "  full     - Complete IT management stack (main server)"
    echo "  edge     - Lightweight edge agent (Portainer agent + Watchtower)"
    echo "  monitor  - Monitoring only (Glances + Watchtower)"
    echo ""
    echo "Examples:"
    echo "  $0 --type full                    # Install full stack"
    echo "  $0 --type edge --dir /opt/edge    # Install edge agent"
    echo "  $0 --type monitor                 # Install monitoring only"
}

install_full() {
    echo "📦 Installing full InfraKit stack..."
    git clone "$REPO_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    ./scripts/setup_env.sh
    echo "✅ Full installation complete!"
    echo "Next steps:"
    echo "1. Edit .env files to customize configuration"
    echo "2. Follow docs/guides/SECRETS_SETUP.md to create secrets"
    echo "3. Run 'make up' to start services"
}

install_edge() {
    echo "🔗 Installing edge agent..."
    
    # Create temporary directory for selective download
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Clone with minimal depth to get only the latest commit
    git clone --depth 1 "$REPO_URL" temp_repo
    cd temp_repo
    
    # Create the target directory
    mkdir -p "$INSTALL_DIR"
    
    # Copy only what we need for edge deployment
    cp -r deployments/edge-agent/* "$INSTALL_DIR"/
    
    # Copy essential scripts for make compatibility
    mkdir -p "$INSTALL_DIR"/scripts
    cp scripts/docker-compose-compat.mk "$INSTALL_DIR"/scripts/
    cp scripts/docker-compose-compat.sh "$INSTALL_DIR"/scripts/
    
    # Clean up temp directory
    cd /
    rm -rf "$TEMP_DIR"
    
    # Go to the installation directory
    cd "$INSTALL_DIR"
    
    # Fix the Makefile path to point to the correct location
    sed -i 's|../../scripts/docker-compose-compat.mk|scripts/docker-compose-compat.mk|g' Makefile
    
    make setup
    echo "✅ Edge agent installation complete!"
    echo "Next steps:"
    echo "1. Edit .env with your main server details"
    echo "2. Run 'make up' to start agent"
}

install_monitor() {
    echo "📊 Installing monitoring stack..."
    
    # Create temporary directory for selective download
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Clone with minimal depth to get only the latest commit
    git clone --depth 1 "$REPO_URL" temp_repo
    cd temp_repo
    
    # Create the target directory
    mkdir -p "$INSTALL_DIR"
    
    # Copy essential files for monitoring deployment
    cp docker-compose.yml "$INSTALL_DIR"/
    cp Makefile "$INSTALL_DIR"/
    cp .env.example "$INSTALL_DIR"/
    
    # Copy monitoring-specific environment file if it exists
    [ -f .env.monitoring ] && cp .env.monitoring "$INSTALL_DIR"/
    
    # Copy necessary scripts
    mkdir -p "$INSTALL_DIR"/scripts
    cp scripts/docker-compose-compat.mk "$INSTALL_DIR"/scripts/
    cp scripts/docker-compose-compat.sh "$INSTALL_DIR"/scripts/
    cp scripts/setup_env.sh "$INSTALL_DIR"/scripts/
    
    # Copy monitoring services
    for service in glances watchtower; do
        if [ -d "$service" ]; then
            cp -r "$service" "$INSTALL_DIR"/
        fi
    done
    
    # Clean up temp directory
    cd /
    rm -rf "$TEMP_DIR"
    
    # Go to the installation directory
    cd "$INSTALL_DIR"
    
    # Set monitoring profile
    if [ -f .env.monitoring ]; then
        cp .env.monitoring .env
    else
        cp .env.example .env
    fi
    
    ./scripts/setup_env.sh
    
    echo "✅ Monitoring installation complete!"
    echo "Next steps:"
    echo "1. Edit .env to customize monitoring settings"
    echo "2. Run 'make up' to start monitoring"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--type)
            DEPLOYMENT_TYPE="$2"
            shift 2
            ;;
        -d|--dir)
            INSTALL_DIR="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Set default installation directory
if [ -z "$INSTALL_DIR" ]; then
    INSTALL_DIR="./infrakit"
fi

# Validate deployment type
if [ -z "$DEPLOYMENT_TYPE" ]; then
    echo "❌ Error: Deployment type is required"
    show_help
    exit 1
fi

# Check if directory exists
if [ -d "$INSTALL_DIR" ]; then
    echo "❌ Error: Directory $INSTALL_DIR already exists"
    exit 1
fi

# Install based on type
case "$DEPLOYMENT_TYPE" in
    full)
        install_full
        ;;
    edge)
        install_edge
        ;;
    monitor)
        install_monitor
        ;;
    *)
        echo "❌ Error: Unknown deployment type: $DEPLOYMENT_TYPE"
        show_help
        exit 1
        ;;
esac

echo ""
echo "🚀 Installation complete!"
echo "📁 Installed in: $INSTALL_DIR"
echo "📖 Check README.md for next steps"
