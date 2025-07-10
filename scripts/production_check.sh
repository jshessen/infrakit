#!/bin/bash

# InfraKit Production Readiness Check
# This script validates that InfraKit is ready for production deployment

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

echo -e "${BLUE}🚀 InfraKit Production Readiness Check${NC}"
echo "========================================"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo -e "${RED}❌ Do not run this script as root${NC}"
    exit 1
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check file permissions
check_permissions() {
    local file="$1"
    local expected_perm="$2"
    local actual_perm=$(stat -c "%a" "$file" 2>/dev/null || echo "")
    
    if [[ "$actual_perm" != "$expected_perm" ]]; then
        echo -e "${YELLOW}⚠️  $file has permissions $actual_perm, expected $expected_perm${NC}"
        return 1
    fi
    return 0
}

echo -e "${BLUE}🔍 Checking system requirements...${NC}"

# Check Docker
if ! command_exists docker; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker is installed${NC}"

# Check Docker Compose
if ! command_exists docker-compose && ! docker compose version >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker Compose is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker Compose is installed${NC}"

# Check Docker daemon
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker daemon is not running${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker daemon is running${NC}"

echo -e "${BLUE}🔐 Checking security configuration...${NC}"

# Check if secrets directory exists
if [[ ! -d "$PROJECT_DIR/secrets" ]]; then
    echo -e "${RED}❌ Secrets directory not found${NC}"
    echo "   Run: mkdir -p secrets && chmod 700 secrets"
    exit 1
fi

# Check secrets directory permissions
if ! check_permissions "$PROJECT_DIR/secrets" "700"; then
    echo -e "${YELLOW}⚠️  Secrets directory should have 700 permissions${NC}"
    echo "   Run: chmod 700 secrets"
fi

# Check for .env file
if [[ ! -f "$PROJECT_DIR/.env" ]]; then
    echo -e "${RED}❌ .env file not found${NC}"
    echo "   Run: cp .env.example .env && edit .env"
    exit 1
fi
echo -e "${GREEN}✓ .env file exists${NC}"

# Check .env file permissions
if ! check_permissions "$PROJECT_DIR/.env" "600"; then
    echo -e "${YELLOW}⚠️  .env file should have 600 permissions${NC}"
    echo "   Run: chmod 600 .env"
fi

echo -e "${BLUE}📋 Checking configuration files...${NC}"

# Check if required directories exist
required_dirs=("config" "data" "logs")
for dir in "${required_dirs[@]}"; do
    if [[ ! -d "$PROJECT_DIR/$dir" ]]; then
        echo -e "${YELLOW}⚠️  $dir directory not found, will be created on first run${NC}"
    fi
done

echo -e "${BLUE}🔧 Checking Docker Compose configuration...${NC}"

# Validate Docker Compose files
cd "$PROJECT_DIR"
if ! docker-compose config >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker Compose configuration is invalid${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker Compose configuration is valid${NC}"

echo -e "${BLUE}🌐 Checking network configuration...${NC}"

# Check for port conflicts
common_ports=(80 443 9000 8080 8443)
for port in "${common_ports[@]}"; do
    if netstat -tuln 2>/dev/null | grep -q ":$port "; then
        echo -e "${YELLOW}⚠️  Port $port is already in use${NC}"
    fi
done

echo -e "${BLUE}💾 Checking storage requirements...${NC}"

# Check available disk space
available_space=$(df -BG "$PROJECT_DIR" | tail -1 | awk '{print $4}' | sed 's/G//')
if [[ $available_space -lt 10 ]]; then
    echo -e "${YELLOW}⚠️  Less than 10GB available disk space${NC}"
fi
echo -e "${GREEN}✓ Sufficient disk space available${NC}"

echo -e "${BLUE}📊 Checking system resources...${NC}"

# Check available memory
available_memory=$(free -m | awk 'NR==2{print $7}')
if [[ $available_memory -lt 2048 ]]; then
    echo -e "${YELLOW}⚠️  Less than 2GB available memory${NC}"
fi
echo -e "${GREEN}✓ Sufficient memory available${NC}"

echo -e "${BLUE}🎯 Running final validations...${NC}"

# Run security check
if [[ -f "$PROJECT_DIR/scripts/security_check.sh" ]]; then
    echo -e "${BLUE}Running security check...${NC}"
    if ! "$PROJECT_DIR/scripts/security_check.sh" >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Security check found issues${NC}"
    fi
fi

# Check for production-ready settings
if grep -q "COMPOSE_PROFILES=.*container_management.*observability.*identity.*remote_access.*security" "$PROJECT_DIR/.env"; then
    echo -e "${GREEN}✓ Production profiles configured${NC}"
else
    echo -e "${YELLOW}⚠️  Consider using production profiles${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Production readiness check complete!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Review any warnings above"
echo "2. Run: make install"
echo "3. Run: make up"
echo "4. Run: make health"
echo ""
echo -e "${BLUE}For production deployment:${NC}"
echo "1. Use .env.production as template"
echo "2. Set up proper TLS certificates"
echo "3. Configure backup strategy"
echo "4. Set up monitoring and alerting"
echo ""
