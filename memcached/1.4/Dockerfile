ARG FROM_TAG=latest
FROM quay.io/continuouspipe/ubuntu16.04:${FROM_TAG}

RUN apt-get update -qq \
 && apt-get -qq -y --no-install-recommends install \
    memcached \
 \
 # Clean the image \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY ./etc /etc
