.DEFAULT_GOAL:=help
# -all:			## 'Start' InfraKit, and all applicable components - 'docker-compose ... up -d [services...]'
	$(call docker_compose,up -d $(ARGS))

up:			## 'Up' InfraKit, and all applicable components - 'docker-compose ... up -d [services...]'
	@make all $(ARGS)

down:			## 'Down' InfraKit, and all applicable components - 'docker-compose ... down [services...]'------------------
-include .env
export
# --------------------------

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
NC := \033[0m # No Color

.PHONY: all up down stop restart rm images update logs install check setup clean


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

logs:			## 'Show logs' for services - 'docker-compose ... logs [services...]'
	$(call docker_compose,logs $(ARGS))

install:		## 'Install' - Set up environment and secrets
	@echo "$(GREEN)🚀 Installing InfraKit$(NC)"
	@./scripts/setup_env.sh
	@echo "$(YELLOW)⚠️  Next: Configure secrets following SECRETS_SETUP.md$(NC)"

check:			## 'Check' - Run security and configuration checks
	@echo "$(BLUE)🔍 Running security checks...$(NC)"
	@./scripts/security_check.sh

docker-check:	## 'Docker Check' - Check Docker Compose compatibility
	@./scripts/check-docker-compose.sh

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

# --------------------------
help:       	## Show this 'help'
	@echo "InfraKit - Self-Hosted Infrastructure Toolkit"
	@echo ""
	@echo "Usage Examples:"
	@echo "  make install                     # Setup environment and guide through secrets"
	@echo "  make up                          # Start all services"
	@echo "  make up portainer dozzle         # Start specific services"
	@echo "  make down portainer              # Stop specific service"
	@echo "  make logs portainer              # Show logs for portainer"
	@echo "  make logs -f --tail=100          # Show logs with docker-compose flags"
	@echo "  make restart authentik caddy     # Restart multiple services"
	@echo ""
	@echo "Note: All arguments after the target are passed directly to docker-compose"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "Targets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
