FROM quay.io/continuouspipe/ubuntu:16.04

MAINTAINER Kieren Evans <kieren.evans@inviqa.com>

RUN curl -sL https://deb.nodesource.com/setup_6.x > /tmp/install-node.sh \
 && bash /tmp/install-node.sh \
 && apt-get update -qq \
 && apt-get install -qqy nodejs \
 && npm config set --global loglevel warn \
 && npm install --global marked \
 && npm install --global node-gyp \
 && npm install --global gulp \
 && npm rebuild node-sass \

 # Clean the image
 && apt-get auto-remove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
