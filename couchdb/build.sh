#!/bin/bash

set -xe

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi ;

# shellcheck disable=SC2043
for IMAGE_TAG in 1.6; do
  sed "s/{{IMAGE_TAG}}/$IMAGE_TAG/g" "${DIR}/Dockerfile.tmpl" > "${DIR}/Dockerfile-${IMAGE_TAG}"
done
