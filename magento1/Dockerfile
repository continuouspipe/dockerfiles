ARG FROM_IMAGE
ARG FROM_TAG=latest
FROM quay.io/continuouspipe/${FROM_IMAGE}:${FROM_TAG}

ARG WEB_SERVER

# Install npm
RUN curl -sL https://deb.nodesource.com/setup_6.x > /tmp/install-node.sh \
 && bash /tmp/install-node.sh \
 && apt-get update -qq -y \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    nodejs \
    rsyslog \
    sudo \
 \
 # Configure Node dependencies \
 && npm config set --global loglevel warn \
 && npm install --global marked \
 && npm install --global node-gyp \
 && npm install --global gulp \
 \
 # Install node-sass's linux bindings \
 && npm rebuild node-sass \
 \
 # Clean the image \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app

COPY ./etc/ ./${WEB_SERVER}/etc/ /etc/
COPY ./usr/ /usr/
