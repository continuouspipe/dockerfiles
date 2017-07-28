FROM quay.io/continuouspipe/symfony-php7.1-nginx:latest

MAINTAINER Hardik Gajjar <hardik.gajjar@inviqa.com>

RUN curl -sL https://deb.nodesource.com/setup_6.x > /tmp/install-node.sh \
 && bash /tmp/install-node.sh \
 && apt-get update -qq -y \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    build-essential \
    graphviz \
    nodejs \
    php7.1-pgsql \
    php7.1-gmp \
    postgresql-client \
    redis-tools \
 \
 # Clean the image \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY ./etc/ /etc/
COPY ./usr/ /usr/
