FROM quay.io/continuouspipe/symfony-php7.1-nginx:latest

ARG NODE_VERSION=7.x
ARG INSTALL_COMMON_PACKAGES=true
ARG PHP_VERSION=7.1

# Install Node.js
RUN curl -sL "https://deb.nodesource.com/setup_$NODE_VERSION" > /tmp/install-node.sh \
 && bash /tmp/install-node.sh \
 && apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    nodejs \
 \
 # Set up common NPM packages \
 && if [ "$INSTALL_COMMON_PACKAGES" = "true" ]; then \
      npm config set --global loglevel warn \
   && npm install --global \
      marked \
      node-gyp \
      gulp \
      yarn \
      npx \
   # Install node-sass's linux bindings \
   && npm rebuild node-sass; \
    fi \
 \
 # Install PHP extensions \
 && apt-get install -y php-amqp \
 \
 # Clean the image \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY ./usr/ /usr
WORKDIR /app
