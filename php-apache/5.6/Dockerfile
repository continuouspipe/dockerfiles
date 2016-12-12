FROM quay.io/continuouspipe/ubuntu:16.04_v1

MAINTAINER Kieren Evans <kieren.evans+cp-dockerfiles@inviqa.com>

RUN echo 'deb http://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages debian main' > /etc/apt/sources.list.d/tideways.list \
 && curl -sS https://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages/EEB5E8F4.gpg | apt-key add - \
 && apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    apache2 \
    apache2-utils \
    curl \
    git \
    fontconfig \
    lbzip2 \
    libapache2-mod-php \
    php-apcu \
    php-imagick \
    php-redis \
    php-curl \
    php-gd \
    php-intl \
    php-mbstring \
    php-mcrypt \
    php-mysql \
    php-xsl \
    php-zip \
    php-soap \
 \
 # Clean the image \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 \
 # Install composer for PHP dependencies - Syntax looks wrong but it works! \
 && php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');" \
 && if [ "$(wget https://composer.github.io/installer.sig -O - -q)" = "$(php -r 'echo hash_file("SHA384", "/tmp/composer-setup.php");')" ]; \
    then \
      php /tmp/composer-setup.php --install-dir='/usr/local/bin/' --filename='composer' --quiet; \
      rm /tmp/composer-setup.php; \
    fi \
 \
 # Enable the correct config for most sites \
 && a2disconf other-vhosts-access-log \
 && a2enmod rewrite

USER build

RUN composer global require "hirak/prestissimo" --no-interaction --no-ansi --quiet --no-progress --prefer-dist \
 && composer clear-cache --no-ansi --quiet \
 && chmod -R go-w ~/.composer/vendor

USER root

# Add configuration
COPY ./etc/ /etc/
COPY ./usr/ /usr/
