FROM quay.io/continuouspipe/php7-nginx:latest

MAINTAINER Kieren Evans <kieren.evans+cp-dockerfiles@inviqa.com>

RUN apt-get update -qq -y \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    rsyslog \
    sudo \
 \
 # Clean the image \
 && apt-get remove -qq -y php7.0-dev pkg-config libmagickwand-dev build-essential \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app

COPY ./etc/ /etc/
COPY ./usr/ /usr/
