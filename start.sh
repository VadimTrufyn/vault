#!/bin/bash

[[ ! -f .env ]] && {
	echo "Please create .env file and put domain"
	exit 1
}

docker compose up -d

while [[ ! $(docker inspect -f {{.State.Health.Status}} vault) == "healthy" ]]; do
		sleep 0.5;
done

docker exec vault /bin/sh -c "source /helpers/init.sh"
