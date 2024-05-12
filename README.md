```
    ____                               ______         ____             __            
   / __ \_________ _____ _____  ____  / __/ /_  __   / __ \____  _____/ /_____  _____
  / / / / ___/ __ `/ __ `/ __ \/ __ \/ /_/ / / / /  / / / / __ \/ ___/ //_/ _ \/ ___/
 / /_/ / /  / /_/ / /_/ / /_/ / / / / __/ / /_/ /  / /_/ / /_/ / /__/ ,< /  __/ /    
/_____/_/   \__,_/\__, /\____/_/ /_/_/ /_/\__, /  /_____/\____/\___/_/|_|\___/_/     
                 /____/                  /____/                                      

## Project Announcements

Stay updated with project announcements by following us on [Twitter](https://twitter.com/webpwnized).

## TL;DR

To quickly run the Dragonfly PHP application using Docker, execute the following command:

```bash
docker-compose --file .build/docker-compose.yml up --detach
```

## Overview

This project provides containerized environments for running the Dragonfly PHP application. The directory structure is as follows:

- **LICENSE**: License file for the project.
- **README.md**: Main documentation file in Markdown format.
- **version**: File containing version information.

The `.build` directory contains Docker-related files:

- **docker-compose.yml**: Docker Compose file to orchestrate container creation and networking.
- **www**: Directory containing Dockerfile for building the `webpwnized/dragonfly:www` image.

The `.tools` directory contains utility scripts for managing the project:

- **list-container-installed-packages.sh**: Script to list installed packages in containers.
- **remove-all-images.sh**: Script to remove all Docker images.
- **update-dragonfly-application.sh**: Script to update the Dragonfly application.
- **git.sh**: Git utility script for managing the project repository.
- **push-to-dockerhub.sh**: Script to push Docker images to Docker Hub.
- **push-development-branch.sh**: Script to push changes to the development branch.
- **start-containers.sh**: Script to start Docker containers.
- **stop-containers.sh**: Script to stop Docker containers.

## Usage

1. **Building Containers**: To build the container image `webpwnized/dragonfly:www`, execute the following command from the project root:

    ```bash
    docker build --file .build/www/Dockerfile --tag webpwnized/dragonfly:www .
    ```

2. **Running Containers**: Start the containers using Docker Compose. From the project root, execute:

    ```bash
    docker-compose --file .build/docker-compose.yml up --detach
    ```

Once the containers are running, you can access the Dragonfly web interface at the following URLs:

- [http://localhost](http://localhost)
- [http://localhost:8088](http://localhost:8088)

Enjoy using Dragonfly!
