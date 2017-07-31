#!/bin/bash

set -xe

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi ;

for IMAGE_TAG in 9.4 9.6; do
  sed "s/{{IMAGE_TAG}}/$IMAGE_TAG/g" "${DIR}/Dockerfile.tmpl" > "${DIR}/Dockerfile-${IMAGE_TAG}"
done
