FROM quay.io/continuouspipe/php-nginx:7.0_v1

MAINTAINER Kieren Evans <kieren.evans+cp-dockerfiles@inviqa.com>

# Install hem and npm
RUN curl -q https://dx6pc3giz7k1r.cloudfront.net/GPG-KEY-inviqa-tools | apt-key add - \
 && echo "deb https://dx6pc3giz7k1r.cloudfront.net/repos/debian jessie main" | tee /etc/apt/sources.list.d/inviqa-tools.list \
 && curl -sL https://deb.nodesource.com/setup_6.x > /tmp/install-node.sh \
 && bash /tmp/install-node.sh \
 && apt-get update -qqy \
 && DEBIAN_FRONTEND=noninteractive apt-get -qqy install \
    hem \
    nodejs \
    rsyslog \
    sudo \

 # Configure Node dependencies
 && npm config set --global loglevel warn \
 && npm install --global marked \
 && npm install --global node-gyp \
 && npm install --global gulp \
 && npm rebuild node-sass \

 # Clean the image
 && apt-get remove -qqy php7.0-dev pkg-config libmagickwand-dev build-essential \
 && apt-get auto-remove -qqy \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \

 # Set up hem directories
 && mkdir -p /home/build/.hem/gems/ \
 && chown -R build:build /home/build/.hem/

WORKDIR /app

COPY ./etc/ /etc/
COPY ./usr/ /usr/
