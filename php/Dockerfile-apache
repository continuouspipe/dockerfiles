ARG PHP_IMAGE_VERSION
ARG FROM_TAG=latest
FROM quay.io/continuouspipe/php${PHP_IMAGE_VERSION}:${FROM_TAG}

RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    apache2 \
    apache2-utils \
    "libapache2-mod-php$PHP_VERSION" \
 && echo -e '; priority=25\nextension=redis.so' > "/etc/php/${PHP_VERSION}/apache2/conf.d/25-redis.ini" \
 && ln -s "/etc/php/${PHP_VERSION}/mods-available/tideways.ini" "/etc/php/${PHP_VERSION}/apache2/conf.d/20-tideways.ini" \
 \
 # Clean the image \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 \
 # Enable the correct config for most sites \
 && a2disconf other-vhosts-access-log \
 && a2enmod remoteip \
 && a2enmod rewrite \
 && a2enmod ssl

# Add configuration
COPY ./apache/etc/ /etc/
COPY ./apache/usr/ /usr/

RUN find /etc/confd/conf.d/ -name "*.toml" -type f -exec sed -i'' "s/\$PHP_VERSION/$PHP_VERSION/" {} \;
