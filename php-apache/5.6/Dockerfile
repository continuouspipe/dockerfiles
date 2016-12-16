FROM quay.io/continuouspipe/ubuntu16.04:v1.0

MAINTAINER Kieren Evans <kieren.evans+cp-dockerfiles@inviqa.com>

RUN echo 'deb http://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages debian main' > /etc/apt/sources.list.d/tideways.list \
 && curl -sS https://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages/EEB5E8F4.gpg | apt-key add - \
 && echo 'deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main' > /etc/apt/sources.list.d/php-ppa.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C \
 && apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    apache2 \
    apache2-utils \
    curl \
    git \
    libapache2-mod-php5.6 \
    php-apcu \
    php-imagick \
    php-redis \
    php5.6-curl \
    php5.6-gd \
    php5.6-intl \
    php5.6-mbstring \
    php5.6-mcrypt \
    php5.6-mysql \
    php5.6-xsl \
    php5.6-zip \
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
