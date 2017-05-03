FROM quay.io/continuouspipe/php7-nginx:latest

MAINTAINER Kieren Evans <kieren.evans+cp-dockerfiles@inviqa.com>

# Install npm
RUN curl -sL https://deb.nodesource.com/setup_6.x > /tmp/install-node.sh \
 && bash /tmp/install-node.sh \
 && apt-get update -qq -y \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    awscli \
    nodejs \
    php-imagick \
    redis-tools \
    rsyslog \
    sudo \
 \
 # Configure Node dependencies \
 && npm config set --global loglevel warn \
 && npm install --global \
    gulp \
    marked \
    node-gyp \
    node-sass \
 \
 # Install node-sass's linux bindings \
 && npm rebuild node-sass \
 && npm cache clean \
 \
 # Clean the image \
 && apt-get remove -qq -y php7.0-dev pkg-config libmagickwand-dev build-essential \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app

COPY ./etc/ /etc/
COPY ./usr/ /usr/
