#!/bin/bash

# Docker Compose Compatibility Detection
# Automatically detects and uses the correct docker-compose command

# Function to detect docker compose command
detect_docker_compose() {
    if command -v docker-compose >/dev/null 2>&1; then
        echo "docker-compose"
    elif docker compose version >/dev/null 2>&1; then
        echo "docker compose"
    else
        echo "ERROR: Neither 'docker-compose' nor 'docker compose' is available"
        exit 1
    fi
}

# Export the command for use in other scripts
export DOCKER_COMPOSE_CMD=$(detect_docker_compose)

# Function to run docker compose with the correct command
docker_compose() {
    $DOCKER_COMPOSE_CMD "$@"
}

# Export the function
export -f docker_compose

# Print which command is being used (optional)
if [ "${DOCKER_COMPOSE_VERBOSE:-false}" = "true" ]; then
    echo "Using Docker Compose command: $DOCKER_COMPOSE_CMD" >&2
fi
