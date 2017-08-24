#!/bin/bash

set -xe

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi ;

for WEB_SERVER in nginx apache; do
    # shellcheck disable=SC2043
    for PHP_VERSION in 5.6; do
        sed "s/{{IMAGE_NAME}}/php${PHP_VERSION}-${WEB_SERVER}/g; s/{{PHP_VERSION}}/$PHP_VERSION/g; s/{{WEB_SERVER}}/$WEB_SERVER/g;" "${DIR}/Dockerfile.tmpl" > "${DIR}/Dockerfile-php${PHP_VERSION}-${WEB_SERVER}"
    done
done

# shellcheck disable=SC2043
for WEB_SERVER in nginx; do
    # shellcheck disable=SC2043
    for PHP_VERSION in 5.5; do
        sed "s/{{IMAGE_NAME}}/eol-php${PHP_VERSION}-${WEB_SERVER}/g;s/{{PHP_VERSION}}/$PHP_VERSION/g; s/{{WEB_SERVER}}/$WEB_SERVER/g;" "${DIR}/Dockerfile.tmpl" > "${DIR}/Dockerfile-eol-php${PHP_VERSION}-${WEB_SERVER}"
    done
done
