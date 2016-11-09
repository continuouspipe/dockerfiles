FROM quay.io/inviqa_images/ubuntu:16.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -yq install \
    curl \
    apache2 \
    apache2-utils \
    libapache2-mod-php7.0 \
    php7.0-intl \
    php7.0-mysql \
    php7.0-mcrypt \
    php7.0-gd \
    php7.0-curl \
    php7.0-xsl \
    php7.0-zip \
    php7.0-mbstring \
    php-imagick \
    php-redis \
    php-apcu \
    git \
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/bin/composer \
    && composer global require hirak/prestissimo \
    && a2disconf other-vhosts-access-log \
    && a2enmod rewrite \

    && \

# Install tideways' extension
    echo 'deb http://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages debian main' > /etc/apt/sources.list.d/tideways.list && \
    curl -sS https://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages/EEB5E8F4.gpg | apt-key add - && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -yq install tideways-php \

    && \

# Clean the image
    apt-get auto-remove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add configuration
COPY etc/ /etc/
