# Docker Compose Compatibility for Makefile
# Detects and uses the correct docker-compose command

# Function to detect docker compose command
DOCKER_COMPOSE_CMD := $(shell \
	if command -v docker-compose >/dev/null 2>&1; then \
		echo "docker-compose"; \
	elif docker compose version >/dev/null 2>&1; then \
		echo "docker compose"; \
	else \
		echo "echo 'ERROR: Neither docker-compose nor docker compose is available' && exit 1"; \
	fi \
)

# Export for use in targets
export DOCKER_COMPOSE_CMD

# Wrapper function for consistent usage
define docker_compose
	$(DOCKER_COMPOSE_CMD) $(1)
endef
