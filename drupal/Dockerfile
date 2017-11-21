ARG PHP_VERSION
ARG FROM_TAG=latest
FROM quay.io/continuouspipe/php${PHP_VERSION}-apache:${FROM_TAG}

RUN curl -sL https://deb.nodesource.com/setup_7.x > /tmp/install-node.sh \
 && bash /tmp/install-node.sh \
 && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
 && apt-get update -qq -y \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    mysql-client \
    nodejs \
    yarn \
 \
 # Clean the image \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 # Enable headers and expires modules \
 && a2enmod expires \
 && a2enmod headers \
 \
 # Install Drupal's CLI tool \
 && curl https://drupalconsole.com/installer -L -o /usr/local/bin/drupal \
 && chmod a+x /usr/local/bin/drupal

USER build

# Install Drupal's Drush tool
RUN composer global require drush/drush:~8.1.10 \
 && composer global clear-cache

USER root

RUN ln -s /home/build/.composer/vendor/bin/drush /usr/local/bin/

COPY ./etc/ /etc
COPY ./usr/ /usr
