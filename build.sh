#!/bin/bash

set -xe

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi ;

echo "Pulling any external images:"; echo
(cd "$DIR" && grep 'external_.*:' "$DIR/docker-compose.yml" | cut -d":" -f1 | xargs docker-compose pull)
echo "Building all images:"; echo
(cd "$DIR" && docker-compose build --force-rm)

read -r -p "Would you like to publish the images? [Y/n] " DO_PUBLISH

if [ -z "$DO_PUBLISH" ]; then
  DO_PUBLISH='y'
fi

DO_PUBLISH="$(echo $DO_PUBLISH | tr '[A-Z]' '[a-z]')"
if [ "$DO_PUBLISH" = 'y' ]; then
  echo "Pushing our images:"; echo
  (cd "$DIR" && docker-compose push)
else
  echo "Not Pushing our images."; echo
fi

echo "Done!"; echo
