ARG PHP_VERSION
ARG WEB_SERVER
ARG FROM_TAG=latest
FROM quay.io/continuouspipe/php${PHP_VERSION}-${WEB_SERVER}:${FROM_TAG}

ARG PHP_VERSION
ARG WEB_SERVER

RUN curl -sL https://deb.nodesource.com/setup_6.x > /tmp/install-node.sh \
 && bash /tmp/install-node.sh \
 && apt-get update -qq -y \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    build-essential \
    graphviz \
    nodejs \
    "php${PHP_VERSION}-gmp" \
    redis-tools \
 \
 # Clean the image \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY ./etc/ ./${WEB_SERVER}/etc/ /etc/
COPY ./usr/ ./${WEB_SERVER}/usr/ /usr/
