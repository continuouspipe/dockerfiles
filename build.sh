#!/bin/bash

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi ;

echo "Pulling any external images:\n"
(cd "$DIR" && grep 'external_.*:' "$DIR/docker-compose.yml" | cut -d":" -f1 | xargs docker-compose pull)
echo "Building all images:\n"
(cd "$DIR" && docker-compose build --force-rm)
