#!/bin/bash

# Stop all running containers
docker stop $(docker ps -q)

# Remove all stopped containers
docker rm $(docker ps -a -q)

# Remove all dangling and unused images
docker image prune -af

# Remove all unused volumes
docker volume prune -f

# Remove all unused networks
docker network prune -f

# Remove all unused resources including containers, networks, images, and volumes
docker system prune -af
