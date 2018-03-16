ARG FROM_TAG=latest
ARG PHP_VERSION=7.1
FROM quay.io/continuouspipe/symfony-php${PHP_VERSION}-nginx:${FROM_TAG}

ARG NODE_VERSION=7.x
ARG INSTALL_COMMON_PACKAGES=true

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
 # Install Blackfire (Tideways is already in the base image) \
 && version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") && \
    curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$version && \
    tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp && \
    mv /tmp/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so && \
    echo "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707" > /etc/php/$PHP_VERSION/mods-available/blackfire.ini \
 \
 # Clean the image \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY ./usr/ /usr
WORKDIR /app
