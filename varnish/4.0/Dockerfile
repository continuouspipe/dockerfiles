ARG FROM_TAG=latest
FROM quay.io/continuouspipe/ubuntu16.04:${FROM_TAG}

# Install Varnish
RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    varnish \
 \
 # Clean the image \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY ./etc/ /etc/
COPY ./usr/ /usr/
