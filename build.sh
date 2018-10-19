#!/bin/bash

set -xe

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")"
else
    DIR="$(dirname "$0")"
fi

shopt -s nullglob
set -- "${DIR}"/*/build.sh
if [ "$#" -gt 0 ]; then
  for file in "$@"; do
    # shellcheck source=/dev/null
    source "${file}"
  done
fi

DOCKER_COMPOSE_FILES=("-f docker-compose.yml")
DOCKER_IMAGES=()
EOL_BUILD="${EOL_BUILD:-false}"
if [ "${EOL_BUILD}" == "true" ]; then
  DOCKER_COMPOSE_FILES+=("-f docker-compose.eol.yml")
  DOCKER_IMAGES+=("php55_nginx" "magento1_php55_nginx")
fi

# external_* services are used to fetch only upstream base images.
# build --pull would otherwise overwrite the newly built dependency of a service with the old repo version
echo "Pulling any external images:"; echo
(cd "$DIR" && grep 'external_.*:' "$DIR/docker-compose.yml" | cut -d":" -f1 | xargs docker-compose pull)
echo "Building all images:"; echo
(cd "$DIR" && docker-compose "${DOCKER_COMPOSE_FILES[@]}" build --force-rm "${DOCKER_IMAGES[@]}")

if [ -z "$DO_PUBLISH" ]; then
  read -r -p "Would you like to publish the images? [Y/n] " DO_PUBLISH
fi

if [ -z "$DO_PUBLISH" ]; then
  DO_PUBLISH='y'
fi

DO_PUBLISH="$(echo "$DO_PUBLISH" | tr '[:upper:]' '[:lower:]')"
if [ "$DO_PUBLISH" = 'y' ]; then
  echo "Pushing our images:"; echo
  (cd "$DIR" && docker-compose "${DOCKER_COMPOSE_FILES[@]}" push "${DOCKER_IMAGES[@]}")
else
  echo "Not Pushing our images."; echo
fi

echo "Done!"; echo
