#!/bin/bash

set -xe

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi ;

for WEB_SERVER in nginx apache; do
    for PHP_VERSION in 5.6 7 7.1; do
        sed "s/{{PHP_VERSION}}/$PHP_VERSION/g; s/{{WEB_SERVER}}/$WEB_SERVER/g;" "${DIR}/Dockerfile.tmpl" > "${DIR}/Dockerfile-php${PHP_VERSION}-${WEB_SERVER}"
    done
done
