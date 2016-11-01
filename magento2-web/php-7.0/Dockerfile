FROM quay.io/inviqa_images/php-nginx:7.0

MAINTAINER Kieren Evans <kieren.evans@inviqa.com>

# Install PHP packages, including the Tideways extension
RUN curl -q https://dx6pc3giz7k1r.cloudfront.net/GPG-KEY-inviqa-tools | apt-key add - \
 && echo "deb https://dx6pc3giz7k1r.cloudfront.net/repos/debian jessie main" | tee /etc/apt/sources.list.d/inviqa-tools.list \
 && curl -sL https://deb.nodesource.com/setup_6.x > /tmp/install-node.sh \
 && bash /tmp/install-node.sh \
 && apt-get update -qqy \
 && DEBIAN_FRONTEND=noninteractive apt-get -qqy install \
    rsyslog \
    hem \
    nodejs \

 # Clean the image
 && apt-get remove -qqy php7.0-dev pkg-config libmagickwand-dev build-essential \
 && apt-get auto-remove -qqy \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./etc/ /etc/

USER build

# Configure Node dependencies
RUN npm config set --global loglevel warn \
 && npm install --global marked \
 && npm install --global node-gyp \
 && npm install --global gulp \
 && npm rebuild node-sass
