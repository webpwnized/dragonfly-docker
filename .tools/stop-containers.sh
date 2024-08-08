#!/bin/bash

# This script stops and removes the containers defined in the Docker Compose file.

# Define the path to the Docker Compose file
DOCKER_COMPOSE_FILE=".build/docker-compose.yml"

# Function to display error message and exit
display_error() {
    echo "Error: $1"
    exit 1
}

# Check if the Docker Compose file exists
if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    display_error "Docker Compose file $DOCKER_COMPOSE_FILE not found."
fi

# Inform the user about the action being performed
echo "Stopping and removing containers defined in $DOCKER_COMPOSE_FILE..."

# Run docker compose down command with the --volumes flag to remove volumes as well
if docker compose -f "$DOCKER_COMPOSE_FILE" down --volumes; then
    echo "Containers stopped and removed successfully."
else
    display_error "Failed to stop and remove containers."
fi
