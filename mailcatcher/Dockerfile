FROM quay.io/continuouspipe/ubuntu16.04:latest
MAINTAINER Kieren Evans <kieren.evans+cp-dockerfiles@inviqa.com>

RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    ruby ruby-dev build-essential libsqlite3-dev \
 \
 &&  {\
      echo 'install: --no-document'; \
      echo 'update: --no-document'; \
    } >> /etc/gemrc \
 && gem install mailcatcher \
 \
 # Clean the image \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y remove ruby-dev build-essential libsqlite3-dev \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && useradd --create-home mailcatcher

COPY ./shared/ /

# smtp port
EXPOSE 1025

# webserver port
EXPOSE 1080
