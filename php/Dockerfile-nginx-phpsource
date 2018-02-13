ARG FROM_TAG=latest
FROM quay.io/continuouspipe/ubuntu16.04:${FROM_TAG}

ARG PHP_FULL_VERSION
ENV PHP_FULL_VERSION=${PHP_FULL_VERSION}
RUN export PHP_VERSION=${PHP_FULL_VERSION%.[0-9]*} \
 && apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    awscli \
    jq \
    nginx \
    postfix \
    mysql-client \
    postgresql-client \
    \
    autoconf \
    automake \
    apache2-dev \
    bison \
    build-essential \
    freetds-dev \
    libbz2-dev \
    libc-client-dev \
    libcurl4-openssl-dev \
    libedit-dev \
    libgd-dev \
    libglib2.0-dev \
    libgmp3-dev \
    libicu-dev \
    libjpeg-dev \
    libltdl-dev \
    "$( dpkg --compare-versions "$PHP_VERSION" ge 7.2 || echo "libmcrypt-dev" )" \
    libmemcached-dev \
    libmysqlclient-dev \
    libpng-dev \
    libpq-dev \
    libjpeg-dev \
    libsqlite3-dev \
    libssl-dev \
    libtidy-dev \
    libwebp-dev \
    libwrap0-dev \
    libxml2-dev \
    libxslt1-dev \
    libzip-dev \
    pkg-config \
    re2c \
    zlib1g-dev \
 \
 # Compile PHP \
 && wget "https://secure.php.net/distributions/php-${PHP_FULL_VERSION}.tar.bz2" \
 && tar -xf "php-${PHP_FULL_VERSION}.tar.bz2" \
 && cd "php-${PHP_FULL_VERSION}" \
 && mkdir build-cli build-fpm \
 && cd build-cli \
 && ln -s ../configure \
 && ./configure \
   --prefix=/usr \
   --sysconfdir=/etc \
   --localstatedir=/var \
   --with-libedit=shared,/usr \
   --enable-cli \
   --disable-cgi \
   --disable-phpdbg \
   --enable-pcntl \
   --enable-bcmath \
   --with-bz2=/usr \
   --with-curl \
   --with-gd \
   --enable-gd-native-ttf \
   --with-freetype-dir=/usr \
   --with-jpeg-dir=/usr \
   --with-png-dir=/usr \
   --with-xpm-dir=/usr/X11R6 \
   --with-webp-dir=/usr \
   --enable-intl \
   --enable-mbstring \
   "$( dpkg --compare-versions "$PHP_VERSION" ge 7.2 || echo "--with-mcrypt" )" \
   --with-mhash \
   --enable-mysqlnd \
   --with-mysql=mysqlnd \
   --with-mysqli=mysqlnd \
   --with-mysql-sock=/var/run/mysqld/mysqld.sock \
   --with-openssl \
   --with-pdo-mysql \
   --with-pdo-pgsql \
   --with-pdo-sqlite \
   --enable-soap \
   --with-sqlite3 \
   --with-tidy \
   --with-xsl \
   --enable-zip \
   --with-zlib \
   "--with-config-file-path=/etc/php/${PHP_VERSION}/cli" \
   "--with-config-file-scan-dir=/etc/php/${PHP_VERSION}/cli/conf.d" \
 && make -j2 \
 && make install \
 && cd .. \
 && cd build-fpm \
 && ln -s ../configure \
 && ./configure \
   --prefix=/usr \
   "--sysconfdir=/etc/php/${PHP_VERSION}/fpm" \
   --localstatedir=/var \
   --enable-fpm \
   --disable-cgi \
   --disable-phpdbg \
   --enable-bcmath \
   --with-bz2=/usr \
   --with-curl \
   --with-gd \
   --enable-gd-native-ttf \
   --with-freetype-dir=/usr \
   --with-jpeg-dir=/usr \
   --with-png-dir=/usr \
   --with-xpm-dir=/usr/X11R6 \
   --with-webp-dir=/usr \
   --enable-intl \
   --enable-mbstring \
   "$( dpkg --compare-versions "$PHP_VERSION" ge 7.2 || echo "--with-mcrypt" )" \
   --with-mhash \
   --enable-mysqlnd \
   --with-mysql=mysqlnd \
   --with-mysqli=mysqlnd \
   --with-mysql-sock=/var/run/mysqld/mysqld.sock \
   --with-openssl \
   --with-pdo-mysql \
   --with-pdo-pgsql \
   --with-pdo-sqlite \
   --enable-soap \
   --with-sqlite3 \
   --with-tidy \
   --with-xsl \
   --enable-zip \
   --with-zlib \
   --with-libevent-dir=/usr \
   --with-fpm-user=www-data --with-fpm-group=www-data \
   "--with-config-file-path=/etc/php/${PHP_VERSION}/fpm" \
   "--with-config-file-scan-dir=/etc/php/${PHP_VERSION}/fpm/conf.d" \
 && make -j2 \
 && make install-fpm \
 && cd ../.. \
 && rm -rf php-${PHP_FULL_VERSION} php-${PHP_FULL_VERSION}.tar.bz2 \
 \
 # update php locations \
 && mv /usr/sbin/php-fpm "/usr/sbin/php-fpm${PHP_VERSION}" \
 \
 # set up configuration folders \
 && mkdir -p "/etc/php/${PHP_VERSION}/cli/conf.d" "/etc/php/${PHP_VERSION}/fpm/conf.d" \
 && mkdir -p "/etc/php/${PHP_VERSION}/fpm/pool.d" \
 \
 # build pecl modules \
 && if bash -c '[[ "${PHP_FULL_VERSION}" =~ ^5\. ]]'; then \
   pecl install memcached-2.2.0; \
 else \
   pecl install memcached; \
 fi \
 && echo -e '; priority=25\nextension=memcached.so' | tee /etc/php/${PHP_VERSION}/fpm/conf.d/25-memcached.ini > /etc/php/${PHP_VERSION}/cli/conf.d/25-memcached.ini \
 \
 # Clean the image \
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

COPY ./shared/ ./nginx/ /

RUN export PHP_VERSION=${PHP_FULL_VERSION%.[0-9]*} \
 && find /etc/confd/conf.d/ -name "*.toml" -type f -exec sed -i'' "s/\$PHP_VERSION/$PHP_VERSION/" {} \;
