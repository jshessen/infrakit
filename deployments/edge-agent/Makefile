.DEFAULT_GOAL:=help

# --------------------------
-include .env
export
# --------------------------

# Docker Compose Compatibility
include ../../scripts/docker-compose-compat.mk

# Extract arguments from command line
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(ARGS):;@:)

.PHONY: all up down stop restart rm images update logs setup

all:		## 'Start' Edge Agent services - 'docker-compose up -d'
	$(call docker_compose,up -d $(ARGS))

up:			## 'Up' Edge Agent services - 'docker-compose up -d'
	@make all $(ARGS)

down:		## 'Down' Edge Agent services - 'docker-compose down'
	$(call docker_compose,down $(ARGS))

stop:		## 'Stop' Edge Agent services - 'docker-compose stop'
	$(call docker_compose,stop $(ARGS))
	
restart:	## 'Restart' Edge Agent services - 'docker-compose restart'
	$(call docker_compose,restart $(ARGS))

rm:			## 'Remove' Edge Agent services - 'docker-compose rm -f'
	$(call docker_compose,rm -f $(ARGS))

images:		## 'Show' Edge Agent images - 'docker-compose images'
	$(call docker_compose,images $(ARGS))

update:		## 'Update' Edge Agent services - 'docker-compose pull/up'
	$(call docker_compose,pull $(ARGS))
	@make all $(ARGS)

logs:		## 'Show logs' for services - 'docker-compose logs'
	$(call docker_compose,logs $(ARGS))

setup:		## 'Setup' environment from example
	@if [ ! -f .env ]; then cp .env.example .env; echo "Created .env from .env.example"; else echo ".env already exists"; fi

# --------------------------
help:		## Show this 'help'
	@echo "Edge Agent Docker Services"
	@echo ""
	@echo "Usage Examples:"
	@echo "  make setup              # Create .env from .env.example"
	@echo "  make up                 # Start all services"
	@echo "  make logs               # Show all logs"
	@echo "  make logs portainer-agent # Show specific service logs"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "Targets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
