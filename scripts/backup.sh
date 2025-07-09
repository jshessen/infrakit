#!/bin/bash

# Backup script for InfraKit

set -e

# Source docker-compose compatibility
source ./scripts/docker-compose-compat.sh

BACKUP_DIR="${BACKUP_DIR:-./backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="infrakit_backup_${TIMESTAMP}"
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}"

echo "💾 InfraKit Backup Script"
echo "========================="
echo ""

# Create backup directory
mkdir -p "$BACKUP_PATH"

echo "📂 Creating backup in: $BACKUP_PATH"
echo ""

# Function to backup a service
backup_service() {
    local service="$1"
    local description="$2"
    
    if [ -d "$service" ]; then
        echo "📋 Backing up $description..."
        
        # Create service backup directory
        mkdir -p "$BACKUP_PATH/$service"
        
        # Copy configuration files
        if [ -f "$service/.env" ]; then
            cp "$service/.env" "$BACKUP_PATH/$service/.env"
        fi
        
        if [ -f "$service/docker-compose.yml" ]; then
            cp "$service/docker-compose.yml" "$BACKUP_PATH/$service/docker-compose.yml"
        fi
        
        # Copy secrets (encrypted)
        if [ -d "$service/secrets" ]; then
            cp -r "$service/secrets" "$BACKUP_PATH/$service/secrets"
        fi
        
        # Backup Docker volumes
        if docker_compose ps | grep -q "$service"; then
            echo "   🗄️  Backing up volumes for $service..."
            docker_compose exec -T "$service" tar czf - /data 2>/dev/null > "$BACKUP_PATH/$service/volumes.tar.gz" || echo "   ⚠️  No volumes to backup"
        fi
        
        echo "   ✅ $description backup complete"
    else
        echo "   ⚠️  $service directory not found, skipping"
    fi
}

# Backup main configuration
echo "📋 Backing up main configuration..."
cp .env "$BACKUP_PATH/.env" 2>/dev/null || echo "   ⚠️  Main .env not found"
cp docker-compose.yml "$BACKUP_PATH/docker-compose.yml" 2>/dev/null || echo "   ⚠️  Main docker-compose.yml not found"
cp Makefile "$BACKUP_PATH/Makefile" 2>/dev/null || echo "   ⚠️  Makefile not found"

# Backup individual services
backup_service "authentik" "Authentik Identity Provider"
backup_service "portainer" "Portainer Container Management"
backup_service "caddy" "Caddy Reverse Proxy"
backup_service "glances" "Glances System Monitor"
backup_service "dozzle" "Dozzle Log Viewer"
backup_service "guacamole" "Guacamole Remote Desktop"
backup_service "watchtower" "Watchtower Auto-Updates"
backup_service "socket-proxy" "Socket Proxy Security"

# Create backup metadata
echo "📋 Creating backup metadata..."
cat > "$BACKUP_PATH/backup_info.txt" << EOF
IT Management Stack Backup
==========================

Backup Date: $(date)
Backup Name: $BACKUP_NAME
System: $(uname -a)
Docker Version: $(docker --version)
Docker Compose Version: $($DOCKER_COMPOSE_CMD --version)

Services Backed Up:
$(ls -la "$BACKUP_PATH")

Notes:
- Secrets are included and should be handled securely
- Volume data may need manual restoration
- Verify .env files before restoration
EOF

# Compress the backup
echo "📦 Compressing backup..."
cd "$BACKUP_DIR"
tar czf "${BACKUP_NAME}.tar.gz" "$BACKUP_NAME"
rm -rf "$BACKUP_NAME"

echo ""
echo "✅ Backup completed successfully!"
echo "📁 Backup file: $BACKUP_DIR/${BACKUP_NAME}.tar.gz"
echo "🔒 Remember to store this backup securely!"
echo ""
echo "🔄 To restore, use: ./restore.sh $BACKUP_DIR/${BACKUP_NAME}.tar.gz"
