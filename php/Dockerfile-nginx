ARG PHP_IMAGE_VERSION
ARG FROM_TAG=latest
FROM quay.io/continuouspipe/php${PHP_IMAGE_VERSION}:${FROM_TAG}

RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    nginx \
    "php$PHP_VERSION-fpm" \
 \
 && echo -e '; priority=25\nextension=redis.so' > "/etc/php/${PHP_VERSION}/fpm/conf.d/25-redis.ini" \
 && ln -s "/etc/php/${PHP_VERSION}/mods-available/tideways.ini" "/etc/php/${PHP_VERSION}/fpm/conf.d/20-tideways.ini" \
 \
 # Clean the image \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY ./nginx/etc/ /etc/
COPY ./nginx/usr/ /usr/

RUN find /etc/confd/conf.d/ -name "*.toml" -type f -exec sed -i'' "s/\$PHP_VERSION/$PHP_VERSION/" {} \;
