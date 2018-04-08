#!/bin/bash
docker-compose config --services | grep -v ^external_ | sort -n | sed -E 's/^(.*)$/    | \1 |/g'
