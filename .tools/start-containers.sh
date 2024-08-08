#!/bin/bash
# Script must be run from the project root directory

# Define file paths
DOCKERFILE_PATH=".build/www/Dockerfile"
DOCKER_COMPOSE_PATH=".build/docker-compose.yml"

echo "Building containers"
docker build --file "$DOCKERFILE_PATH" --tag webpwnized/dragonfly:www .

echo "Starting containers"
docker compose --file "$DOCKER_COMPOSE_PATH" up --detach
echo "Containers started successfully"
