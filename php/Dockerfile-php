ARG FROM_TAG=latest
FROM quay.io/continuouspipe/ubuntu16.04:${FROM_TAG}

# Install PHP packages, including the Tideways extension
ARG PHP_VERSION
ENV PHP_VERSION=${PHP_VERSION:-7.0}
RUN echo 'deb http://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages debian main' > /etc/apt/sources.list.d/tideways.list \
 && curl -sS https://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages/EEB5E8F4.gpg | apt-key add - \
 && if [ "$PHP_VERSION" != "7.0" ]; then \
   echo 'deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main' > /etc/apt/sources.list.d/php-ppa.list; \
   apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C; \
 fi \
 && apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    awscli \
    jq \
    "php$PHP_VERSION-bcmath" \
    "php$PHP_VERSION-bz2" \
    "php$PHP_VERSION-curl" \
    "php$PHP_VERSION-dev" \
    "php$PHP_VERSION-gd" \
    "php$PHP_VERSION-intl" \
    "php$PHP_VERSION-mbstring" \
    "$( dpkg --compare-versions "$PHP_VERSION" ge 7.2 || echo "php$PHP_VERSION-mcrypt" )" \
    "php$PHP_VERSION-opcache" \
    "php$PHP_VERSION-soap" \
    "php$PHP_VERSION-xsl" \
    "php$PHP_VERSION-zip" \
    "php$PHP_VERSION-mysql" mysql-client \
    "php$PHP_VERSION-pgsql" postgresql-client \
    "php$PHP_VERSION-sqlite3" \
    postfix \
 # Install pear + pecl extensions + tideways after PHP so the right CLI gets selected beforehand \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    php-apcu \
    php-imagick \
    php-memcached \
    php-pear \
    php-xdebug \
    tideways-php \
 \
 # php-redis 4 from php$PHP_VERSION-redis has backwards-incompatibilities so install from pecl repositories \
 && pecl install redis-3.1.6 \
 && echo -e '; priority=25\nextension=redis.so' > "/etc/php/${PHP_VERSION}/cli/conf.d/25-redis.ini" \
 \
 # Clean the image \
 && apt-get remove -y "php$PHP_VERSION-dev" \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 \
 # Install composer for PHP dependencies \
 && wget https://getcomposer.org/installer -O /tmp/composer-setup.php -q \
 && [ "$(wget https://composer.github.io/installer.sig -O - -q)" = "$(sha384sum /tmp/composer-setup.php | awk '{ print $1 }')" ] \
 && php /tmp/composer-setup.php --install-dir='/usr/local/bin/' --filename='composer' --quiet \
 && rm /tmp/composer-setup.php

USER build

RUN composer global require "hirak/prestissimo" --no-interaction --no-ansi --quiet --no-progress --prefer-dist \
 && composer clear-cache --no-ansi --quiet \
 && chmod -R go-w ~/.composer/vendor

USER root

COPY ./shared/etc/ /etc/
COPY ./shared/usr/ /usr/

RUN find /etc/confd/conf.d/ -name "*.toml" -type f -exec sed -i'' "s/\$PHP_VERSION/$PHP_VERSION/" {} \;
