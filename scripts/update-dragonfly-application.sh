#!/bin/bash
# This is a Bash script for updating the web application in a running www container.

# Check if the 'www' container is running
if [ ! "$(docker ps -q -f name=www)" ]; then
    echo "";
    echo "The 'www' container is not running so the application cannot be updated on the container.";
    exit 1;
fi;

# Print a newline for better readability.
echo "";

# Inform the user about the update process.
echo "Updating the application installed in the running 'www' container.";

# Use 'docker exec' to execute commands inside the 'www' container.
# First, ensure Git is installed by running 'apt install git -y' within the container.
docker exec -it  -u root www /bin/bash -c "apt update; apt install git -y; cd /var/www/dragonfly; git pull; echo \"Application Version: \$(cat version)\";"
