FROM quay.io/continuouspipe/ubuntu:16.04_v1

MAINTAINER Kieren Evans <kieren.evans+cp-dockerfiles@inviqa.com>

# Install PHP packages, including the Tideways extension
RUN echo 'deb http://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages debian main' > /etc/apt/sources.list.d/tideways.list \
 && curl -sS https://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages/EEB5E8F4.gpg | apt-key add - \
 && apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -qqy install \
    nginx \
    mysql-client \
    php-apcu \
    php-redis \
    php7.0-bcmath \
    php7.0-bz2 \
    php7.0-curl \
    php7.0-fpm \
    php7.0-gd \
    php7.0-intl \
    php7.0-mbstring \
    php7.0-mcrypt \
    php7.0-mysql \
    php7.0-soap \
    php7.0-xsl \
    php7.0-zip \
    tideways-php \
 \
 # Clean the image \
 && apt-get auto-remove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 \
 # Install composer for PHP dependencies - Syntax looks wrong but it works! \
 && php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');" \
 && if [ "$(wget https://composer.github.io/installer.sig -O - -q)" = "$(php -r 'echo hash_file("SHA384", "/tmp/composer-setup.php");')" ]; \
    then \
      php /tmp/composer-setup.php --install-dir='/usr/local/bin/' --filename='composer' --quiet; \
      rm /tmp/composer-setup.php; \
    fi

USER build

RUN composer global require "hirak/prestissimo" --no-interaction --no-ansi --quiet --no-progress --prefer-dist \
 && composer clear-cache --no-ansi --quiet \
 && chmod -R go-w ~/.composer/vendor

USER root

COPY ./etc/ /etc/
COPY ./usr/ /usr/
