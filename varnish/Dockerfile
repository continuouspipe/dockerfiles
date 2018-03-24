ARG FROM_TAG=latest
FROM quay.io/continuouspipe/ubuntu16.04:${FROM_TAG}

ARG VARNISH_VERSION=41

# Install Varnish
RUN if [ "$VARNISH_VERSION" != "41" ]; then \
   curl -L "https://packagecloud.io/varnishcache/varnish$VARNISH_VERSION/gpgkey" | apt-key add - \
   && echo 'deb "https://packagecloud.io/varnishcache/varnish$VARNISH_VERSION/ubuntu/" xenial main' > /etc/apt/sources.list.d/varnish.list; \
 fi \
 && apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    varnish \
 \
 # Clean the image \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY ./etc/ /etc/
COPY ./usr/ /usr/
