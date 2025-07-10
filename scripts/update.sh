#!/bin/bash

# InfraKit Update Script
# Safely updates InfraKit installation with backup and rollback capabilities

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKUP_DIR="$PROJECT_ROOT/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="$BACKUP_DIR/backup_$TIMESTAMP"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

show_help() {
    echo -e "${CYAN}InfraKit Update Script${NC}"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --check-only      Check for updates without applying them"
    echo "  --backup-only     Create backup without updating"
    echo "  --no-backup       Skip backup creation (not recommended)"
    echo "  --force           Force update even if no changes detected"
    echo "  --rollback        Rollback to previous backup"
    echo "  --list-backups    List available backups"
    echo "  -h, --help        Show this help"
    echo ""
    echo "Examples:"
    echo "  $0                       # Standard update with backup"
    echo "  $0 --check-only          # Check what would be updated"
    echo "  $0 --backup-only         # Create backup only"
    echo "  $0 --rollback            # Rollback to last backup"
}

print_header() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                           🚀 InfraKit Updater                                ║${NC}"
    echo -e "${CYAN}║                     Safe updates with backup & rollback                     ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

check_prerequisites() {
    echo -e "${BLUE}🔍 Checking prerequisites...${NC}"
    
    # Check if we're in a git repository
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo -e "${RED}❌ Error: Not in a git repository${NC}"
        exit 1
    fi
    
    # Check if Docker is running
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}❌ Error: Docker is not running${NC}"
        exit 1
    fi
    
    # Check if docker-compose is available
    if ! command -v docker-compose >/dev/null 2>&1; then
        echo -e "${RED}❌ Error: docker-compose not found${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Prerequisites check passed${NC}"
}

create_backup() {
    echo -e "${BLUE}📦 Creating backup...${NC}"
    
    mkdir -p "$BACKUP_DIR"
    mkdir -p "$BACKUP_PATH"
    
    # Backup configuration files
    cp -r "$PROJECT_ROOT/.env"* "$BACKUP_PATH/" 2>/dev/null || true
    cp -r "$PROJECT_ROOT/secrets" "$BACKUP_PATH/" 2>/dev/null || true
    
    # Backup Docker volumes (if any persistent data)
    if docker volume ls -q | grep -q "infrakit"; then
        echo -e "${BLUE}📁 Backing up Docker volumes...${NC}"
        docker run --rm -v infrakit_data:/data -v "$BACKUP_PATH":/backup alpine tar czf /backup/volumes.tar.gz -C /data . 2>/dev/null || true
    fi
    
    # Save current git commit
    git rev-parse HEAD > "$BACKUP_PATH/git_commit.txt"
    
    # Save current service status
    make ps > "$BACKUP_PATH/services_status.txt" 2>/dev/null || true
    
    echo -e "${GREEN}✅ Backup created: $BACKUP_PATH${NC}"
    echo -e "${GREEN}   Backup includes: configs, secrets, volumes, git commit${NC}"
}

check_updates() {
    echo -e "${BLUE}🔄 Checking for updates...${NC}"
    
    # Fetch latest changes
    git fetch origin >/dev/null 2>&1
    
    # Check if there are updates
    CURRENT_COMMIT=$(git rev-parse HEAD)
    LATEST_COMMIT=$(git rev-parse origin/main)
    
    if [ "$CURRENT_COMMIT" = "$LATEST_COMMIT" ]; then
        echo -e "${YELLOW}📋 No updates available${NC}"
        return 1
    fi
    
    echo -e "${GREEN}📋 Updates available!${NC}"
    echo -e "${BLUE}Current commit: ${CURRENT_COMMIT:0:8}${NC}"
    echo -e "${BLUE}Latest commit:  ${LATEST_COMMIT:0:8}${NC}"
    
    # Show what changed
    echo -e "${BLUE}📝 Changes since last update:${NC}"
    git log --oneline "$CURRENT_COMMIT..$LATEST_COMMIT" | head -10
    
    return 0
}

apply_updates() {
    echo -e "${BLUE}🔄 Applying updates...${NC}"
    
    # Stop services gracefully
    echo -e "${BLUE}⏹️  Stopping services...${NC}"
    make down || true
    
    # Pull latest code
    echo -e "${BLUE}📥 Pulling latest code...${NC}"
    git pull origin main
    
    # Check for new environment variables
    echo -e "${BLUE}🔧 Checking configuration...${NC}"
    if [ -f ".env.example" ]; then
        # Compare with current .env and show new variables
        if [ -f ".env" ]; then
            NEW_VARS=$(comm -23 <(grep -E '^[A-Z_]+=' .env.example | cut -d= -f1 | sort) <(grep -E '^[A-Z_]+=' .env | cut -d= -f1 | sort))
            if [ -n "$NEW_VARS" ]; then
                echo -e "${YELLOW}⚠️  New environment variables detected:${NC}"
                echo "$NEW_VARS"
                echo -e "${YELLOW}   Please review and update your .env file${NC}"
            fi
        fi
    fi
    
    # Pull latest Docker images
    echo -e "${BLUE}🐳 Pulling latest Docker images...${NC}"
    make update
    
    echo -e "${GREEN}✅ Updates applied successfully${NC}"
}

run_health_check() {
    echo -e "${BLUE}🏥 Running health checks...${NC}"
    
    # Wait for services to start
    sleep 10
    
    # Check if services are running
    if command -v "$SCRIPT_DIR/health_check.sh" >/dev/null 2>&1; then
        bash "$SCRIPT_DIR/health_check.sh"
    else
        # Basic health check
        make ps
        echo -e "${GREEN}✅ Services appear to be running${NC}"
    fi
}

rollback() {
    echo -e "${BLUE}🔄 Rolling back to previous version...${NC}"
    
    # Find latest backup
    LATEST_BACKUP=$(ls -t "$BACKUP_DIR" | head -1)
    if [ -z "$LATEST_BACKUP" ]; then
        echo -e "${RED}❌ No backups found${NC}"
        exit 1
    fi
    
    ROLLBACK_PATH="$BACKUP_DIR/$LATEST_BACKUP"
    echo -e "${BLUE}📦 Rolling back to: $ROLLBACK_PATH${NC}"
    
    # Stop services
    make down || true
    
    # Restore git commit
    if [ -f "$ROLLBACK_PATH/git_commit.txt" ]; then
        git checkout "$(cat "$ROLLBACK_PATH/git_commit.txt")"
    fi
    
    # Restore configuration
    cp -r "$ROLLBACK_PATH"/.env* "$PROJECT_ROOT/" 2>/dev/null || true
    cp -r "$ROLLBACK_PATH/secrets" "$PROJECT_ROOT/" 2>/dev/null || true
    
    # Restore volumes
    if [ -f "$ROLLBACK_PATH/volumes.tar.gz" ]; then
        docker run --rm -v infrakit_data:/data -v "$ROLLBACK_PATH":/backup alpine tar xzf /backup/volumes.tar.gz -C /data 2>/dev/null || true
    fi
    
    # Start services
    make up
    
    echo -e "${GREEN}✅ Rollback completed${NC}"
}

list_backups() {
    echo -e "${BLUE}📦 Available backups:${NC}"
    
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR")" ]; then
        echo -e "${YELLOW}No backups found${NC}"
        return
    fi
    
    for backup in $(ls -t "$BACKUP_DIR"); do
        backup_path="$BACKUP_DIR/$backup"
        backup_date=$(date -d "${backup#backup_}" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "Unknown date")
        backup_size=$(du -sh "$backup_path" | cut -f1)
        
        echo -e "${GREEN}📁 $backup${NC}"
        echo -e "   Date: $backup_date"
        echo -e "   Size: $backup_size"
        
        if [ -f "$backup_path/git_commit.txt" ]; then
            commit=$(cat "$backup_path/git_commit.txt")
            echo -e "   Commit: ${commit:0:8}"
        fi
        echo ""
    done
}

# Parse command line arguments
CHECK_ONLY=false
BACKUP_ONLY=false
NO_BACKUP=false
FORCE_UPDATE=false
ROLLBACK=false
LIST_BACKUPS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --check-only)
            CHECK_ONLY=true
            shift
            ;;
        --backup-only)
            BACKUP_ONLY=true
            shift
            ;;
        --no-backup)
            NO_BACKUP=true
            shift
            ;;
        --force)
            FORCE_UPDATE=true
            shift
            ;;
        --rollback)
            ROLLBACK=true
            shift
            ;;
        --list-backups)
            LIST_BACKUPS=true
            shift
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

# Main execution
cd "$PROJECT_ROOT"
print_header

if [ "$LIST_BACKUPS" = true ]; then
    list_backups
    exit 0
fi

if [ "$ROLLBACK" = true ]; then
    rollback
    exit 0
fi

check_prerequisites

if [ "$BACKUP_ONLY" = true ]; then
    create_backup
    exit 0
fi

# Check for updates
if check_updates || [ "$FORCE_UPDATE" = true ]; then
    if [ "$CHECK_ONLY" = true ]; then
        echo -e "${BLUE}✅ Update check completed${NC}"
        exit 0
    fi
    
    # Create backup unless skipped
    if [ "$NO_BACKUP" != true ]; then
        create_backup
    fi
    
    # Apply updates
    apply_updates
    
    # Run health checks
    run_health_check
    
    echo ""
    echo -e "${GREEN}🎉 Update completed successfully!${NC}"
    echo -e "${GREEN}📦 Backup available at: $BACKUP_PATH${NC}"
    echo -e "${GREEN}🔄 To rollback if needed: $0 --rollback${NC}"
else
    if [ "$CHECK_ONLY" != true ]; then
        echo -e "${YELLOW}✅ No updates needed${NC}"
    fi
fi
