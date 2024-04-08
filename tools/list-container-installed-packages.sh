#!/bin/bash

# Function to display container information
display_container_info() {
    local container_id=$1
    echo ""
    echo "--------------"
    echo "$container_id"
    echo "--------------"
    echo ""
    docker exec "$container_id" dpkg -l
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not accessible."
    exit 1
fi

# Get the list of running containers
container_ids=$(docker ps --quiet)

# Check if any containers are running
if [ -z "$container_ids" ]; then
    echo "No running containers found."
    exit 0
fi

# Display information for each running container
for container_id in $container_ids; do
    display_container_info "$container_id"
done
