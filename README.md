```
    ____                               ______         ____             __            
   / __ \_________ _____ _____  ____  / __/ /_  __   / __ \____  _____/ /_____  _____
  / / / / ___/ __ `/ __ `/ __ \/ __ \/ /_/ / / / /  / / / / __ \/ ___/ //_/ _ \/ ___/
 / /_/ / /  / /_/ / /_/ / /_/ / / / / __/ / /_/ /  / /_/ / /_/ / /__/ ,< /  __/ /    
/_____/_/   \__,_/\__, /\____/_/ /_/_/ /_/\__, /  /_____/\____/\___/_/|_|\___/_/     
                 /____/                  /____/                                      
```

Code to containerize the Dragonfly PHP application

## Project Announcements

* **Twitter**: [https://twitter.com/webpwnized](https://twitter.com/webpwnized)

## TLDR

	docker-compose up -d

## Instructions

The application is run from containers in this project. 

- **www** - Apache, PHP, and application source code. The web site is exposed on ports 80,and 8088.

The Dockerfile files in each directory contain the instructions to build each container. The docker-compose.yml file contains the instructions to set up networking for the container, and kick off the builds specified in the Dockerfile files.

## Build

To build the container image webpwnized/dragonfly:www, from project root, build with:

    docker build --file .build/www/Dockerfile --tag webpwnized/dragonfly:www .

## Run

Run From project root, run with:

    docker-compose --file .build/docker-compose.yml up --detach
	
Once the containers are running, the following services are available on localhost.

- Port 80, 8088: Dragonfly HTTP web interface
