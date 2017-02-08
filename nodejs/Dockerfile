FROM quay.io/continuouspipe/ubuntu16.04:latest

MAINTAINER Kieren Evans <kieren.evans+cp-dockerfiles@inviqa.com>

# Install node
ARG NODE_VERSION
ENV NODE_VERSION ${NODE_VERSION:-7.x}
RUN curl -sL "https://deb.nodesource.com/setup_$NODE_VERSION" > /tmp/install-node.sh \
 && bash /tmp/install-node.sh \
 && apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    nodejs \
 \
 # Set up common NPM packages \
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
 && rm -rf /var/lib/apt/lists/*
