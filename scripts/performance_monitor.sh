#!/bin/bash

# InfraKit Performance Monitoring Script
# Monitors system performance and container health

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}📊 InfraKit Performance Monitor${NC}"
echo "================================="

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to get human-readable size
human_readable_size() {
    local size=$1
    if [[ $size -gt 1073741824 ]]; then
        echo "$(( size / 1073741824 ))GB"
    elif [[ $size -gt 1048576 ]]; then
        echo "$(( size / 1048576 ))MB"
    elif [[ $size -gt 1024 ]]; then
        echo "$(( size / 1024 ))KB"
    else
        echo "${size}B"
    fi
}

# Check system resources
echo -e "${BLUE}🖥️  System Resources:${NC}"
echo "===================="

# CPU information
echo -e "${GREEN}CPU:${NC}"
cpu_count=$(nproc)
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
echo "  Cores: $cpu_count"
echo "  Usage: ${cpu_usage}%"

# Memory information
echo -e "${GREEN}Memory:${NC}"
mem_info=$(free -b)
total_mem=$(echo "$mem_info" | awk 'NR==2{print $2}')
used_mem=$(echo "$mem_info" | awk 'NR==2{print $3}')
free_mem=$(echo "$mem_info" | awk 'NR==2{print $4}')
mem_usage=$(( used_mem * 100 / total_mem ))

echo "  Total: $(human_readable_size $total_mem)"
echo "  Used: $(human_readable_size $used_mem) (${mem_usage}%)"
echo "  Free: $(human_readable_size $free_mem)"

# Disk information
echo -e "${GREEN}Disk:${NC}"
df_output=$(df -B1 "$PROJECT_DIR" | tail -1)
total_disk=$(echo "$df_output" | awk '{print $2}')
used_disk=$(echo "$df_output" | awk '{print $3}')
free_disk=$(echo "$df_output" | awk '{print $4}')
disk_usage=$(echo "$df_output" | awk '{print $5}')

echo "  Total: $(human_readable_size $total_disk)"
echo "  Used: $(human_readable_size $used_disk) ($disk_usage)"
echo "  Free: $(human_readable_size $free_disk)"

echo ""

# Docker information
echo -e "${BLUE}🐳 Docker Information:${NC}"
echo "======================"

if command_exists docker; then
    # Docker system info
    echo -e "${GREEN}Docker System:${NC}"
    docker_info=$(docker system df 2>/dev/null || echo "Unable to get Docker system info")
    echo "$docker_info"
    
    echo ""
    
    # Container status
    echo -e "${GREEN}Container Status:${NC}"
    cd "$PROJECT_DIR"
    
    if command_exists docker-compose; then
        compose_cmd="docker-compose"
    else
        compose_cmd="docker compose"
    fi
    
    if $compose_cmd ps --format table 2>/dev/null; then
        echo ""
    else
        echo "No containers running or accessible"
    fi
    
    echo ""
    
    # Container resource usage
    echo -e "${GREEN}Container Resource Usage:${NC}"
    if docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}" 2>/dev/null; then
        echo ""
    else
        echo "Unable to get container stats"
    fi
else
    echo -e "${RED}Docker is not installed or not accessible${NC}"
fi

echo ""

# Network information
echo -e "${BLUE}🌐 Network Status:${NC}"
echo "=================="

# Check key ports
key_ports=(80 443 9000 8080 8443 3000 5000)
echo -e "${GREEN}Port Status:${NC}"
for port in "${key_ports[@]}"; do
    if netstat -tuln 2>/dev/null | grep -q ":$port "; then
        echo "  Port $port: ${GREEN}LISTENING${NC}"
    else
        echo "  Port $port: ${YELLOW}CLOSED${NC}"
    fi
done

echo ""

# Service health checks
echo -e "${BLUE}🏥 Service Health:${NC}"
echo "=================="

cd "$PROJECT_DIR"

# Check if services are responding
services=(
    "portainer:9000"
    "dozzle:8080"
    "glances:61208"
    "caddy:80"
    "authentik:9000"
)

echo -e "${GREEN}Service Connectivity:${NC}"
for service in "${services[@]}"; do
    service_name=$(echo "$service" | cut -d':' -f1)
    service_port=$(echo "$service" | cut -d':' -f2)
    
    if nc -z localhost "$service_port" 2>/dev/null; then
        echo "  $service_name: ${GREEN}RESPONDING${NC}"
    else
        echo "  $service_name: ${YELLOW}NOT RESPONDING${NC}"
    fi
done

echo ""

# Performance recommendations
echo -e "${BLUE}💡 Performance Recommendations:${NC}"
echo "================================="

# Check CPU usage
cpu_usage_num=$(echo "$cpu_usage" | sed 's/%//')
if [[ ${cpu_usage_num%.*} -gt 80 ]]; then
    echo -e "${RED}• High CPU usage detected (${cpu_usage})${NC}"
    echo "  Consider scaling down services or upgrading hardware"
fi

# Check memory usage
if [[ $mem_usage -gt 80 ]]; then
    echo -e "${RED}• High memory usage detected (${mem_usage}%)${NC}"
    echo "  Consider adding more RAM or reducing service memory limits"
fi

# Check disk usage
disk_usage_num=$(echo "$disk_usage" | sed 's/%//')
if [[ $disk_usage_num -gt 80 ]]; then
    echo -e "${RED}• High disk usage detected ($disk_usage)${NC}"
    echo "  Consider cleaning up old containers/images or adding storage"
fi

# Check if all services are running
if $compose_cmd ps -q 2>/dev/null | wc -l | grep -q "^0$"; then
    echo -e "${YELLOW}• No services currently running${NC}"
    echo "  Run 'make up' to start services"
fi

echo ""
echo -e "${GREEN}✓ Performance monitoring complete${NC}"
echo ""
echo -e "${BLUE}For continuous monitoring:${NC}"
echo "• Set up Glances dashboard (included in stack)"
echo "• Configure Grafana alerts (see dockprom integration)"
echo "• Use 'make health' for quick health checks"
echo "• Run this script regularly or set up as cron job"
echo ""
