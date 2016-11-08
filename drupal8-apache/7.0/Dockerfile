FROM quay.io/inviqa_images/php-apache:7.0

MAINTAINER "Kieren Evans <kevans@inviqa.com>"

RUN curl -q https://dx6pc3giz7k1r.cloudfront.net/GPG-KEY-inviqa-tools | apt-key add - \
 && echo "deb https://dx6pc3giz7k1r.cloudfront.net/repos/debian jessie main" | tee /etc/apt/sources.list.d/inviqa-tools.list \
 && apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -qqy install \
    hem \
    mysql-client \

 # Clean the image
 && apt-get auto-remove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \

 && composer global require drush/drush \
 && ln -s ~/.composer/vendor/bin/drush /usr/local/bin/ \

 && composer global config minimum-stability RC \
 && composer global require drupal/console:~1.0 \
 && ln -s ~/.composer/vendor/bin/drupal /usr/local/bin/ \

 && composer global clear-cache

COPY ./etc/ /etc
COPY ./usr/ /usr
