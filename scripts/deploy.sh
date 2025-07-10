#!/bin/bash

# InfraKit Deployment Script
# Handles different deployment scenarios: full, edge, monitoring, production

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Default values
DEPLOYMENT_TYPE="full"
ENVIRONMENT="development"
INTERACTIVE=true
SKIP_CHECKS=false

# Usage function
usage() {
    echo -e "${CYAN}InfraKit Deployment Script${NC}"
    echo "=========================="
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -t, --type TYPE       Deployment type: full, edge, monitoring, production"
    echo "  -e, --env ENV         Environment: development, staging, production"
    echo "  -y, --yes             Non-interactive mode (auto-confirm)"
    echo "  -s, --skip-checks     Skip pre-deployment checks"
    echo "  -h, --help            Show this help message"
    echo ""
    echo "Deployment Types:"
    echo "  full                  Complete IT management solution (default)"
    echo "  edge                  Lightweight edge device deployment"
    echo "  monitoring            Monitoring-focused deployment"
    echo "  production            Production-ready full deployment"
    echo ""
    echo "Examples:"
    echo "  $0 --type full --env development"
    echo "  $0 --type edge --env production --yes"
    echo "  $0 --type monitoring --skip-checks"
    echo ""
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--type)
            DEPLOYMENT_TYPE="$2"
            shift 2
            ;;
        -e|--env)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -y|--yes)
            INTERACTIVE=false
            shift
            ;;
        -s|--skip-checks)
            SKIP_CHECKS=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            exit 1
            ;;
    esac
done

# Validate deployment type
case $DEPLOYMENT_TYPE in
    full|edge|monitoring|production)
        ;;
    *)
        echo -e "${RED}Invalid deployment type: $DEPLOYMENT_TYPE${NC}"
        usage
        exit 1
        ;;
esac

# Validate environment
case $ENVIRONMENT in
    development|staging|production)
        ;;
    *)
        echo -e "${RED}Invalid environment: $ENVIRONMENT${NC}"
        usage
        exit 1
        ;;
esac

echo -e "${BLUE}🚀 InfraKit Deployment${NC}"
echo "======================="
echo -e "${CYAN}Deployment Type:${NC} $DEPLOYMENT_TYPE"
echo -e "${CYAN}Environment:${NC} $ENVIRONMENT"
echo -e "${CYAN}Interactive:${NC} $INTERACTIVE"
echo ""

# Function to confirm action
confirm() {
    if [[ "$INTERACTIVE" == "true" ]]; then
        read -p "$1 (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Operation cancelled${NC}"
            exit 1
        fi
    fi
}

# Change to project directory
cd "$PROJECT_DIR"

# Pre-deployment checks
if [[ "$SKIP_CHECKS" == "false" ]]; then
    echo -e "${BLUE}🔍 Running pre-deployment checks...${NC}"
    
    # Check system requirements
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker is not installed${NC}"
        exit 1
    fi
    
    if ! command -v docker-compose >/dev/null 2>&1 && ! docker compose version >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker Compose is not installed${NC}"
        exit 1
    fi
    
    # Check Docker daemon
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker daemon is not running${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ System requirements met${NC}"
fi

# Set up environment based on deployment type and environment
echo -e "${BLUE}🔧 Setting up environment...${NC}"

ENV_FILE=".env"
case $DEPLOYMENT_TYPE in
    full)
        if [[ "$ENVIRONMENT" == "production" ]]; then
            ENV_TEMPLATE=".env.production"
        else
            ENV_TEMPLATE=".env.example"
        fi
        ;;
    edge)
        ENV_TEMPLATE=".env.edge"
        ;;
    monitoring)
        ENV_TEMPLATE=".env.monitoring"
        ;;
    production)
        ENV_TEMPLATE=".env.production"
        ;;
esac

# Copy environment template if it doesn't exist
if [[ ! -f "$ENV_FILE" ]]; then
    if [[ -f "$ENV_TEMPLATE" ]]; then
        cp "$ENV_TEMPLATE" "$ENV_FILE"
        echo -e "${GREEN}✓ Created $ENV_FILE from $ENV_TEMPLATE${NC}"
    else
        echo -e "${RED}❌ Environment template $ENV_TEMPLATE not found${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  $ENV_FILE already exists${NC}"
    confirm "Do you want to overwrite it with $ENV_TEMPLATE?"
    cp "$ENV_TEMPLATE" "$ENV_FILE"
    echo -e "${GREEN}✓ Updated $ENV_FILE from $ENV_TEMPLATE${NC}"
fi

# Set appropriate permissions
chmod 600 "$ENV_FILE"

# Create necessary directories
echo -e "${BLUE}📁 Creating necessary directories...${NC}"
mkdir -p secrets config data logs
chmod 700 secrets

# Set up profiles based on deployment type
case $DEPLOYMENT_TYPE in
    full)
        if [[ "$ENVIRONMENT" == "production" ]]; then
            PROFILES="container_management,observability,identity,remote_access,security,auto_update"
        else
            PROFILES="container_management,observability,identity,remote_access,security"
        fi
        ;;
    edge)
        PROFILES="container_management_agent,auto_update"
        ;;
    monitoring)
        PROFILES="observability,auto_update"
        ;;
    production)
        PROFILES="container_management,observability,identity,remote_access,security,auto_update"
        ;;
esac

# Update profiles in .env file
if grep -q "COMPOSE_PROFILES=" "$ENV_FILE"; then
    sed -i "s/COMPOSE_PROFILES=.*/COMPOSE_PROFILES=$PROFILES/" "$ENV_FILE"
else
    echo "COMPOSE_PROFILES=$PROFILES" >> "$ENV_FILE"
fi

echo -e "${GREEN}✓ Configured profiles: $PROFILES${NC}"

# Run security check if not skipped
if [[ "$SKIP_CHECKS" == "false" ]]; then
    echo -e "${BLUE}🔐 Running security check...${NC}"
    if [[ -f "scripts/security_check.sh" ]]; then
        ./scripts/security_check.sh
    fi
fi

# Production-specific checks
if [[ "$ENVIRONMENT" == "production" ]]; then
    echo -e "${BLUE}🏭 Production environment detected${NC}"
    
    # Check for secrets
    if [[ ! -d "secrets" ]] || [[ -z "$(ls -A secrets 2>/dev/null)" ]]; then
        echo -e "${YELLOW}⚠️  No secrets found${NC}"
        echo "Please set up secrets before continuing:"
        echo "  1. Read SECRETS_SETUP.md"
        echo "  2. Run ./scripts/setup_env.sh"
        echo "  3. Generate required secrets"
        confirm "Continue without secrets setup?"
    fi
    
    # Run production readiness check
    if [[ -f "scripts/production_check.sh" ]]; then
        echo -e "${BLUE}Running production readiness check...${NC}"
        ./scripts/production_check.sh
    fi
fi

# Show deployment summary
echo -e "${BLUE}📋 Deployment Summary${NC}"
echo "===================="
echo -e "${CYAN}Type:${NC} $DEPLOYMENT_TYPE"
echo -e "${CYAN}Environment:${NC} $ENVIRONMENT"
echo -e "${CYAN}Profiles:${NC} $PROFILES"
echo -e "${CYAN}Config:${NC} $ENV_FILE"
echo ""

# Confirm deployment
confirm "Deploy InfraKit with these settings?"

# Deploy services
echo -e "${BLUE}🚀 Starting deployment...${NC}"

# Use appropriate Docker Compose command
if command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_CMD="docker-compose"
else
    COMPOSE_CMD="docker compose"
fi

# Pull latest images
echo -e "${BLUE}📦 Pulling latest images...${NC}"
$COMPOSE_CMD pull

# Start services
echo -e "${BLUE}🔄 Starting services...${NC}"
$COMPOSE_CMD up -d

# Wait for services to start
echo -e "${BLUE}⏳ Waiting for services to start...${NC}"
sleep 10

# Check service status
echo -e "${BLUE}📊 Checking service status...${NC}"
$COMPOSE_CMD ps

# Show access information
echo ""
echo -e "${GREEN}🎉 Deployment complete!${NC}"
echo "======================="
echo ""
echo -e "${BLUE}Access Information:${NC}"

case $DEPLOYMENT_TYPE in
    full|production)
        echo "• Portainer: http://localhost:9000"
        echo "• Glances: http://localhost:61208"
        echo "• Dozzle: http://localhost:8080"
        if [[ "$PROFILES" == *"identity"* ]]; then
            echo "• Authentik: http://localhost:9000"
        fi
        if [[ "$PROFILES" == *"remote_access"* ]]; then
            echo "• Guacamole: http://localhost:8080"
        fi
        ;;
    edge)
        echo "• Portainer Agent: Connects to main server"
        echo "• Watchtower: Automatic updates enabled"
        ;;
    monitoring)
        echo "• Glances: http://localhost:61208"
        echo "• Dozzle: http://localhost:8080"
        ;;
esac

echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "1. Configure services through their web interfaces"
echo "2. Set up additional secrets if needed"
echo "3. Configure external access (if required)"
echo "4. Set up monitoring and alerting"
echo ""
echo -e "${BLUE}Management Commands:${NC}"
echo "• View logs: make logs"
echo "• Check status: make status"
echo "• Health check: make health"
echo "• Performance: make performance"
echo "• Stop services: make down"
echo ""

# Final environment-specific messages
if [[ "$ENVIRONMENT" == "production" ]]; then
    echo -e "${RED}🚨 Production Environment Notes:${NC}"
    echo "• Ensure TLS certificates are configured"
    echo "• Set up proper backup procedures"
    echo "• Configure monitoring and alerting"
    echo "• Review and test disaster recovery procedures"
    echo "• Keep secrets secure and regularly rotated"
    echo ""
fi

echo -e "${GREEN}✓ InfraKit deployment successful!${NC}"
