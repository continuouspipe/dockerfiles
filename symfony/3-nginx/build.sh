#!/bin/bash

set -xe

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi ;

for PHP_VERSION in 5.6 7.0 7.1; do
  sed "s/{{PHP_VERSION}}/$PHP_VERSION/g" $DIR/Dockerfile.tmpl > $DIR/Dockerfile-${PHP_VERSION}
done
