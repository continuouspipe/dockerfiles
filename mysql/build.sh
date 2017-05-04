#!/bin/bash

set -xe

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi ;

for IMAGE_TAG in 5.5 5.6 5.7 8.0; do
  sed "s/{{IMAGE_TAG}}/$IMAGE_TAG/g" "${DIR}/Dockerfile.tmpl" > "${DIR}/Dockerfile-${IMAGE_TAG}"
done
