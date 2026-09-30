#!/bin/bash

# Default path to the Docker Compose file relative to repo root
DEFAULT_COMPOSE_FILE=".build/docker-compose.yml"
DOCKER_COMPOSE_FILE="$DEFAULT_COMPOSE_FILE"

PURGE_PROJECT_IMAGES=false
PURGE_VOLUMES=true
SYSTEM_WIDE_PRUNE=false

# Function to display help / usage
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] [FILE_PATH]

Stops and completely removes Docker containers, networks, and volumes 
associated with this project.

Arguments:
  FILE_PATH                  Path to docker-compose.yml (optional)

Options:
  -f, --file FILE_PATH       Specify path to docker-compose.yml file
  --rmi, --images            Also remove Docker images built/used by this project
  --no-volumes               Do NOT remove persistent volumes associated with this project
  --system                   [DANGER] Perform a system-wide prune of ALL unused Docker resources
  -h, --help                 Display this help message and exit

Examples:
  $(basename "$0") .build/docker-compose.yml
  $(basename "$0") --rmi .build/docker-compose.yml
  $(basename "$0") -f .build/docker-compose.yml --rmi
  $(basename "$0") --system
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

# Parse options and arguments
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
        --rmi|--images)
            PURGE_PROJECT_IMAGES=true
            shift
            ;;
        --no-volumes)
            PURGE_VOLUMES=false
            shift
            ;;
        --system)
            SYSTEM_WIDE_PRUNE=true
            shift
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

# 1. Project-Scoped Removal via Docker Compose
if [[ -f "$DOCKER_COMPOSE_FILE" ]]; then
    echo "Cleaning up containers and resources defined in $DOCKER_COMPOSE_FILE..."
    
    COMPOSE_ARGS=(-f "$DOCKER_COMPOSE_FILE" down --remove-orphans)
    
    if [[ "$PURGE_VOLUMES" == "true" ]]; then
        COMPOSE_ARGS+=(--volumes)
    fi
    
    if [[ "$PURGE_PROJECT_IMAGES" == "true" ]]; then
        COMPOSE_ARGS+=(--rmi all)
    fi

    if docker compose "${COMPOSE_ARGS[@]}"; then
        echo "Project resources removed successfully."
    else
        display_error "Failed to tear down project containers via '$DOCKER_COMPOSE_FILE'."
    fi
else
    echo "Warning: Compose file '$DOCKER_COMPOSE_FILE' not found. Skipping scoped tear-down." >&2
fi

# 2. Optional System-Wide Prune Guard
if [[ "$SYSTEM_WIDE_PRUNE" == "true" ]]; then
    echo ""
    echo "================================================================="
    echo "WARNING: Performing a system-wide Docker prune..."
    echo "This will destroy ALL stopped containers, unused networks,"
    echo "dangling images, and unattached volumes across the ENTIRE system."
    echo "================================================================="
    read -p "Are you sure you want to proceed? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker system prune -af --volumes
        echo "System-wide prune complete."
    else
        echo "System-wide prune canceled."
    fi
fi