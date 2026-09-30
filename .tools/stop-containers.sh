#!/bin/bash

# Default path to the Docker Compose file relative to repo root
DEFAULT_COMPOSE_FILE=".build/docker-compose.yml"
DOCKER_COMPOSE_FILE="$DEFAULT_COMPOSE_FILE"

# Function to display help / usage
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] [FILE_PATH]

Stops running Docker containers defined in the Docker Compose configuration file.

Arguments:
  FILE_PATH                  Path to docker-compose.yml (optional)

Options:
  -f, --file FILE_PATH       Specify path to docker-compose.yml file
  -h, --help                 Display this help message and exit

Examples:
  $(basename "$0") -f .build/docker-compose.yml
  $(basename "$0") .build/docker-compose.yml
EOF
    exit 0
}

display_error() {
    echo "Error: $1" >&2
    exit 1
}

# Display help menu if no parameters/arguments are provided
if [[ $# -eq 0 ]]; then
    usage
fi

# Parse options and positional arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            ;;
        -f|--file)
            if [[ -n "$2" && "$2" != -* ]]; then
                DOCKER_COMPOSE_FILE="$2"
                shift 2
            else
                display_error "Option $1 requires a non-empty file path argument."
            fi
            ;;
        -*)
            display_error "Unknown option: $1 (use -h or --help for usage)"
            ;;
        *)
            # Treat positional argument as file path
            DOCKER_COMPOSE_FILE="$1"
            shift
            ;;
    esac
done

# Ensure docker CLI is installed
if ! command -v docker &> /dev/null; then
    display_error "Docker CLI is not installed or not available in PATH."
fi

# Check if the Docker Compose file exists
if [[ ! -f "$DOCKER_COMPOSE_FILE" ]]; then
    display_error "Docker Compose file '$DOCKER_COMPOSE_FILE' not found."
fi

echo "Stopping containers defined in $DOCKER_COMPOSE_FILE..."

# Execute docker compose stop (does NOT remove containers or volumes)
if docker compose -f "$DOCKER_COMPOSE_FILE" stop; then
    echo "Containers stopped successfully."
else
    display_error "Failed to stop containers using '$DOCKER_COMPOSE_FILE'."
fi