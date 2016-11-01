FROM quay.io/inviqa_images/ubuntu:16.04

MAINTAINER Kieren Evans <kieren.evans@inviqa.com>

# Install PHP packages, including the Tideways extension
RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -qqy install \
    nginx \

 # Clean the image
 && apt-get auto-remove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && echo "daemon off;" >> /etc/nginx/nginx.conf
