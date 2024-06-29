#!/bin/bash

[[ -f data/helpers/keys.json ]] && rm data/helpers/keys.json
find data/file/ -depth -path "data/file/.gitkeep" -o -delete

docker compose down --remove-orphans
