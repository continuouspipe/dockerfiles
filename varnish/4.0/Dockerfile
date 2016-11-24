FROM quay.io/continuouspipe/ubuntu:16.04_v1

MAINTAINER Kieren Evans <kieren.evans+cp-dockerfiles@inviqa.com>

# Install Varnish
RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -qqy --no-install-recommends install \
    varnish \
 \
 # Clean the image \
 && apt-get auto-remove -qqy \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY ./etc/ /etc/
COPY ./usr/ /usr/
