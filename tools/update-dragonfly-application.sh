#!/bin/bash

# Define container name
CONTAINER_NAME="www"

# Check if the container exists
if ! docker inspect "$CONTAINER_NAME" &>/dev/null; then
    echo "Error: The '$CONTAINER_NAME' container does not exist."
    exit 1
fi

# Check if the container is running
if ! docker ps --quiet --filter "name=$CONTAINER_NAME" >/dev/null; then
    echo "Error: The '$CONTAINER_NAME' container is not running. Application cannot be updated."
    exit 1
fi

# Inform the user about the update process
echo "Updating the application installed in the running '$CONTAINER_NAME' container..."

# Update the application inside the container
if ! docker exec "$CONTAINER_NAME" /bin/bash -c "apt update && apt install -y git && cd /var/www/dragonfly && git pull && echo \"Application Version: \$(cat version)\""; then
    echo "Error: Failed to update the application in the container."
    exit 1
fi

echo "Application update completed successfully."
