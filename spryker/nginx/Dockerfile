FROM quay.io/continuouspipe/symfony-php7.1-nginx:latest

MAINTAINER Hardik Gajjar <hardik.gajjar@inviqa.com>

RUN apt-get update \
 && apt-get install -y php7.1-pgsql php7.1-gmp postgresql-client graphviz redis-tools \
 && curl -sL https://deb.nodesource.com/setup_6.x | bash -\
 && apt-get install -y nodejs build-essential \
 && npm install -g antelope \
 \
 # Clean the image \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY ./usr/ /usr/
