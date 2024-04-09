#!/bin/bash

# Define container name and temporary directory
CONTAINER_NAME="www"
TMP_DIR="/tmp/dragonfly"
APP_PATH="/var/www/dragonfly"

# Function to handle errors
handle_error() {
    echo "Error: $1"
    exit 1
}

# Check if the container exists
echo "Checking if the '$CONTAINER_NAME' container exists..."
docker inspect "$CONTAINER_NAME" &>/dev/null || handle_error "The '$CONTAINER_NAME' container does not exist."
echo "Container '$CONTAINER_NAME' found."

# Check if the container is running
echo "Checking if the '$CONTAINER_NAME' container is running..."
docker ps --quiet --filter "name=$CONTAINER_NAME" >/dev/null || handle_error "The '$CONTAINER_NAME' container is not running. Application cannot be updated."
echo "Container '$CONTAINER_NAME' is running."

# Inform the user about the update process
echo "Updating the application installed in the running '$CONTAINER_NAME' container..."

# Install needed software inside the container
echo "Installing necessary software (git) inside the container..."
docker exec -u root "$CONTAINER_NAME" /bin/bash -c "apt update && apt install -y git" || handle_error "Failed to install git in the container."
echo "Git installed successfully."

# Clone the updated application from the repository
echo "Cloning the updated application from the repository..."
docker exec -u root "$CONTAINER_NAME" /bin/bash -c "git clone https://github.com/webpwnized/dragonfly.git $TMP_DIR" || handle_error "Failed to clone the updated application from the repository."
echo "Application cloned successfully."

# Move the updated application to the correct location and clean up the temporary directory
echo "Moving the updated application to the correct location and cleaning up..."
docker exec -u root "$CONTAINER_NAME" /bin/bash -c "rm -rf $APP_PATH && mv $TMP_DIR/src $APP_PATH && rm -rf $TMP_DIR" || handle_error "Failed to move the updated application to the correct location."
echo "Application update completed successfully."
