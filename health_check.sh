#!/bin/bash

# Health check script for IT Management services

echo "🏥 IT Management Health Check"
echo "============================="
echo ""

# Function to check if a service is healthy
check_service_health() {
    local service_name="$1"
    local service_port="$2"
    local protocol="${3:-http}"
    
    echo -n "🔍 Checking $service_name... "
    
    # Check if container is running
    if ! docker-compose ps | grep -q "$service_name.*Up"; then
        echo "❌ Container not running"
        return 1
    fi
    
    # Check if port is responding
    if [ -n "$service_port" ]; then
        if timeout 5 bash -c "</dev/tcp/localhost/$service_port" 2>/dev/null; then
            echo "✅ Healthy"
            return 0
        else
            echo "⚠️  Port $service_port not responding"
            return 1
        fi
    else
        echo "✅ Running"
        return 0
    fi
}

# Function to get service URL
get_service_url() {
    local service="$1"
    local port="$2"
    echo "   🔗 http://localhost:$port"
}

echo "📋 Service Health Status:"
echo ""

# Check services based on profile
if docker-compose ps | grep -q "authentik"; then
    check_service_health "authentik" "9000"
    get_service_url "Authentik" "9000"
fi

if docker-compose ps | grep -q "portainer"; then
    check_service_health "portainer" "9000"
    get_service_url "Portainer" "9000"
fi

if docker-compose ps | grep -q "caddy"; then
    check_service_health "caddy" "8080"
    get_service_url "Caddy" "8080"
fi

if docker-compose ps | grep -q "dozzle"; then
    check_service_health "dozzle" "8080"
    get_service_url "Dozzle" "8080"
fi

if docker-compose ps | grep -q "glances"; then
    check_service_health "glances" "61208"
    get_service_url "Glances" "61208"
fi

if docker-compose ps | grep -q "guacamole"; then
    check_service_health "guacamole" "8080"
    get_service_url "Guacamole" "8080"
fi

if docker-compose ps | grep -q "watchtower"; then
    check_service_health "watchtower"
fi

if docker-compose ps | grep -q "socket-proxy"; then
    check_service_health "socket-proxy" "2375"
fi

echo ""
echo "🐳 Docker System Info:"
echo "   📊 Containers: $(docker ps -q | wc -l) running"
echo "   💾 Images: $(docker images -q | wc -l) total"
echo "   🔗 Networks: $(docker network ls -q | wc -l) total"
echo "   📁 Volumes: $(docker volume ls -q | wc -l) total"

echo ""
echo "💽 System Resources:"
echo "   🧠 Memory: $(free -h | grep '^Mem:' | awk '{print $3 "/" $2}')"
echo "   💿 Disk: $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 " used)"}')"

echo ""
echo "✅ Health check complete!"
