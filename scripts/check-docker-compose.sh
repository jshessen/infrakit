#!/bin/bash

# Docker Compose Version Detection and Information Script

echo "🐳 Docker Compose Compatibility Check"
echo "====================================="
echo ""

# Function to check Docker Compose availability
check_docker_compose() {
    echo "🔍 Detecting Docker Compose installation..."
    echo ""
    
    # Check for docker-compose (V1)
    if command -v docker-compose >/dev/null 2>&1; then
        echo "✅ Found docker-compose (V1 standalone)"
        echo "   Command: docker-compose"
        echo "   Version: $(docker-compose --version)"
        echo "   Location: $(which docker-compose)"
        COMPOSE_V1=true
    else
        echo "❌ docker-compose (V1) not found"
        COMPOSE_V1=false
    fi
    
    echo ""
    
    # Check for docker compose (V2)
    if docker compose version >/dev/null 2>&1; then
        echo "✅ Found docker compose (V2 plugin)"
        echo "   Command: docker compose"
        echo "   Version: $(docker compose version)"
        COMPOSE_V2=true
    else
        echo "❌ docker compose (V2) not found"
        COMPOSE_V2=false
    fi
    
    echo ""
    
    # Determine which to use
    if [ "$COMPOSE_V1" = true ] && [ "$COMPOSE_V2" = true ]; then
        echo "🎯 Both versions available!"
        echo "   Recommendation: Use 'docker compose' (V2) - it's newer and actively maintained"
        echo "   This project will automatically use V2 when both are available"
        RECOMMENDED_CMD="docker compose"
    elif [ "$COMPOSE_V1" = true ]; then
        echo "🎯 Using docker-compose (V1)"
        echo "   Note: Consider upgrading to Docker Compose V2"
        RECOMMENDED_CMD="docker-compose"
    elif [ "$COMPOSE_V2" = true ]; then
        echo "🎯 Using docker compose (V2)"
        echo "   Perfect! You're using the modern version"
        RECOMMENDED_CMD="docker compose"
    else
        echo "❌ No Docker Compose installation found!"
        echo ""
        echo "📋 Installation Instructions:"
        echo ""
        echo "Option 1: Install Docker Compose V2 (recommended)"
        echo "   curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose"
        echo "   chmod +x /usr/local/bin/docker-compose"
        echo ""
        echo "Option 2: Install via Docker Desktop (includes V2 plugin)"
        echo "   Download from: https://www.docker.com/products/docker-desktop"
        echo ""
        echo "Option 3: Install via package manager"
        echo "   Ubuntu/Debian: apt-get install docker-compose-plugin"
        echo "   CentOS/RHEL: yum install docker-compose-plugin"
        echo ""
        exit 1
    fi
    
    echo ""
    echo "🛠️  Project Configuration:"
    echo "   This project automatically detects and uses the correct command"
    echo "   Current detection: $RECOMMENDED_CMD"
    echo ""
    echo "✅ Compatibility check complete!"
}

# Run the check
check_docker_compose
