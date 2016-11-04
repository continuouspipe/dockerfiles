FROM quay.io/inviqa_images/php-apache:7.0

MAINTAINER "Kieren Evans <kevans@inviqa.com>"

RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -qqy install \
    mysql-client \

 # Clean the image
 && apt-get auto-remove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \

 && composer global require drush/drush \
 && ln -s ~/.composer/vendor/bin/drush /usr/local/bin/

COPY ./etc/ /etc
COPY ./usr/ /usr
