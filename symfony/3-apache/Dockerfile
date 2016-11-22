FROM quay.io/continuouspipe/php-apache:7.0_v1

RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -yq install \
    acl \

 # Clean the image
 && apt-get auto-remove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY ./etc/ /etc
COPY ./usr/ /usr
