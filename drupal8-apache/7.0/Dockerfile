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

 # Install Drupal's Drush tool
 && composer global require drush/drush \
 && ln -s ~/.composer/vendor/bin/drush /usr/local/bin/ \
 && composer global clear-cache \

 # Install Drupal's CLI tool
 && curl https://drupalconsole.com/installer -L -o /usr/local/bin/drupal \
 && chmod a+x /usr/local/bin/drupal \
 && /usr/local/bin/drupal init --no-interaction

COPY ./etc/ /etc
COPY ./usr/ /usr
