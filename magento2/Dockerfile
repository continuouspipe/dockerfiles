ARG FROM_IMAGE
ARG FROM_TAG=latest
FROM quay.io/continuouspipe/${FROM_IMAGE}:${FROM_TAG}
ARG REQUIRE_HEM=${REQUIRE_HEM:-false}
ARG HEM_PACKAGE=""
# Install hem and npm
RUN if [ "$REQUIRE_HEM" = "true" ]; \
    then \
         curl -q https://dx6pc3giz7k1r.cloudfront.net/GPG-KEY-inviqa-tools | apt-key add - \
      && echo "deb https://dx6pc3giz7k1r.cloudfront.net/repos/debian jessie main" | tee /etc/apt/sources.list.d/inviqa-tools.list \
      && HEM_PACKAGE=hem;\
    fi \
 && curl -sL https://deb.nodesource.com/setup_6.x > /tmp/install-node.sh \
 && bash /tmp/install-node.sh \
 && apt-get update -qq -y \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    awscli \
    "$HEM_PACKAGE" \
    nodejs \
    php-imagick \
    redis-tools \
    rsyslog \
    sudo \
 \
 # Configure Node dependencies \
 && npm config set --global loglevel warn \
 && npm install --global \
    gulp \
    marked \
    node-gyp \
    node-sass \
 \
 # Install node-sass's linux bindings \
 && npm rebuild node-sass \
 && npm cache clean \
 \
 # Clean the image \
 && apt-get remove -qq -y php7.0-dev pkg-config libmagickwand-dev build-essential \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 \
 # Set up hem directories \
 && if [ "$REQUIRE_HEM" = "true" ]; \
     then \
      mkdir -p /home/build/.hem/gems/ \
   && chown -R build:build /home/build/.hem/ ;\
    fi

WORKDIR /app

COPY ./etc/ /etc/
COPY ./usr/ /usr/
