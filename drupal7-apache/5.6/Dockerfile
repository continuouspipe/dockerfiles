FROM quay.io/continuouspipe/php-apache:5.6_v1

MAINTAINER "Kieren Evans <kieren.evans+cp-dockerfiles@inviqa.com>"

RUN curl -q https://dx6pc3giz7k1r.cloudfront.net/GPG-KEY-inviqa-tools | apt-key add - \
 && echo "deb https://dx6pc3giz7k1r.cloudfront.net/repos/debian jessie main" | tee /etc/apt/sources.list.d/inviqa-tools.list \
 && curl -sL https://deb.nodesource.com/setup_6.x > /tmp/install-node.sh \
 && bash /tmp/install-node.sh \
 && apt-get update -qq -y \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    hem \
    mysql-client \
    nodejs \
 \
 # Clean the image \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 \
 # Install Drupal's CLI tool \
 && curl https://drupalconsole.com/installer -L -o /usr/local/bin/drupal \
 && chmod a+x /usr/local/bin/drupal \
 \
 # Set up hem directories \
 && mkdir -p /home/build/.hem/gems/ \
 && chown -R build:build /home/build/.hem/

USER build

# Install Drupal's Drush tool
RUN composer global require drush/drush \
 && composer global clear-cache \
 \
 # Initialise Drupal CLI tool \
 && /usr/local/bin/drupal init --no-interaction

USER root

RUN ln -s /home/build/.composer/vendor/bin/drush /usr/local/bin/

COPY ./etc/ /etc
COPY ./usr/ /usr
