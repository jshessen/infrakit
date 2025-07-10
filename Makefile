.DEFAULT_GOAL:=help

# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║                            🏗️ InfraKit 📦                                    ║
# ║                     Self-Hosted Infrastructure Toolkit                       ║
# ║                                                                              ║
# ║  Docker • Security • Monitoring • Automation                                 ║
# ║  Repository: https://github.com/jshessen/infrakit                            ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# Environment Variables
-include .env
export

# Docker Compose Compatibility
include scripts/docker-compose-compat.mk

# Extract arguments from command line
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(ARGS):;@:)

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
CYAN := \033[0;36m
NC := \033[0m # No Color

.PHONY: all up down stop restart rm images update update-safe update-check logs install check setup clean


all:		## 'Start' IT Management, and all applicable components - 'docker-compose ... up -d [services...]'
	$(call docker_compose,up -d $(ARGS))

up:   ## 'Up' IT Management, and all applicable components - 'docker-compose ... up -d [services...]'
	@make all $(ARGS)

down:   ## 'Down' IT Management, and all applicable components - 'docker-compose ... down [services...]'
	$(call docker_compose,down $(ARGS))

stop:			## 'Stop' InfraKit, and all applicable components - 'docker-compose ... stop [services...]'
	$(call docker_compose,stop $(ARGS))
	
restart:			## 'Restart' InfraKit, and all applicable components - 'docker-compose ... restart [services...]'
	$(call docker_compose,restart $(ARGS))

rm:			## 'Remove' InfraKit, and all applicable components - 'docker-compose ... rm -f [services...]'
	$(call docker_compose,rm -f $(ARGS))

images:			## 'Show' InfraKit, and all applicable components - 'docker-compose ... images [services...]'
	$(call docker_compose,images $(ARGS))

update:			## 'Update' InfraKit, and all applicable components - 'docker-compose ... pull/up [services...]'
	$(call docker_compose,pull $(ARGS))
	@make all $(ARGS)

update-safe:		## 'Safe Update' - Use update script with backup and rollback capabilities
	@./scripts/update.sh

update-check:		## 'Check Updates' - Check for available updates without applying
	@./scripts/update.sh --check-only

logs:			## 'Show logs' for services - 'docker-compose ... logs [services...]'
	$(call docker_compose,logs $(ARGS))

install:		## 'Install' - Set up environment and secrets
	@echo "$(GREEN)🚀 Installing InfraKit$(NC)"
	@./scripts/setup_env.sh
	@echo "$(YELLOW)⚠️  Next: Configure secrets following docs/guides/SECRETS_SETUP.md$(NC)"

check:			## 'Check' - Run security and configuration checks
	@echo "$(BLUE)🔍 Running security checks...$(NC)"
	@./scripts/security_check.sh
	@echo "$(BLUE)🎨 Validating branding integration...$(NC)"
	@./scripts/validate_branding.sh

docker-check:	## 'Docker Check' - Check Docker Compose compatibility
	@./scripts/check-docker-compose.sh

branding-check:	## 'Branding Check' - Validate branding integration
	@./scripts/validate_branding.sh

setup:			## 'Setup' - Initialize environment files
	@./scripts/setup_env.sh

clean:			## 'Clean' - Remove containers, volumes, and networks
	@echo "$(RED)🧹 Cleaning up containers, volumes, and networks...$(NC)"
	$(call docker_compose,down -v --remove-orphans)
	@docker system prune -f

status:			## 'Status' - Show status of all services
	@echo "$(BLUE)📊 Service Status:$(NC)"
	$(call docker_compose,ps)

health:			## 'Health' - Check health of running services
	@echo "$(BLUE)🏥 Health Check:$(NC)"
	$(call docker_compose,ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}")

production-check:	## 'Production Check' - Validate production readiness
	@./scripts/production_check.sh

pre-commit-check:	## 'Pre-Commit Check' - Comprehensive validation before committing
	@./scripts/pre_commit_check.sh

performance:		## 'Performance' - Monitor system and container performance
	@./scripts/performance_monitor.sh

deploy:			## 'Deploy' - Interactive deployment script
	@./scripts/deploy.sh

# --------------------------
help:       	## Show this 'help'
	@echo "$(CYAN)╔══════════════════════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(CYAN)║                            🏗️ InfraKit 📦                                   ║$(NC)"
	@echo "$(CYAN)║                     Self-Hosted Infrastructure Toolkit                      ║$(NC)"
	@echo "$(CYAN)║                                                                              ║$(NC)"
	@echo "$(CYAN)║  Docker • Security • Monitoring • Automation                                ║$(NC)"
	@echo "$(CYAN)║  Repository: https://github.com/jshessen/infrakit                           ║$(NC)"
	@echo "$(CYAN)╚══════════════════════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(BLUE)📖 Usage Examples:$(NC)"
	@echo "  $(GREEN)make install$(NC)                     # Setup environment and guide through secrets"
	@echo "  $(GREEN)make up$(NC)                          # Start all services"
	@echo "  $(GREEN)make up portainer dozzle$(NC)         # Start specific services"
	@echo "  $(GREEN)make down portainer$(NC)              # Stop specific service"
	@echo "  $(GREEN)make logs portainer$(NC)              # Show logs for portainer"
	@echo "  $(GREEN)make logs -f --tail=100$(NC)          # Show logs with docker-compose flags"
	@echo "  $(GREEN)make restart authentik caddy$(NC)     # Restart multiple services"
	@echo ""
	@echo "$(YELLOW)💡 Note: All arguments after the target are passed directly to docker-compose$(NC)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "Targets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
