FROM quay.io/continuouspipe/php7-nginx:v1.0

MAINTAINER Kieren Evans <kieren.evans+cp-dockerfiles@inviqa.com>

# Install hem and npm
RUN curl -q https://dx6pc3giz7k1r.cloudfront.net/GPG-KEY-inviqa-tools | apt-key add - \
 && echo "deb https://dx6pc3giz7k1r.cloudfront.net/repos/debian jessie main" | tee /etc/apt/sources.list.d/inviqa-tools.list \
 && curl -sL https://deb.nodesource.com/setup_6.x > /tmp/install-node.sh \
 && bash /tmp/install-node.sh \
 && apt-get update -qq -y \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    hem \
    nodejs \
    rsyslog \
    sudo \
 \
 # Configure Node dependencies \
 && npm config set --global loglevel warn \
 && npm install --global marked \
 && npm install --global node-gyp \
 && npm install --global gulp \
 \
 # Install node-sass's linux bindings \
 && npm rebuild node-sass \
 \
 # Clean the image \
 && apt-get remove -qq -y php7.0-dev pkg-config libmagickwand-dev build-essential \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 \
 # Set up hem directories \
 && mkdir -p /home/build/.hem/gems/ \
 && chown -R build:build /home/build/.hem/

WORKDIR /app

COPY ./etc/ /etc/
COPY ./usr/ /usr/

ENV PHP_MEMORY_LIMIT=768M \
\
    PRODUCTION_ENVIRONMENT=false \
    APP_HOSTNAME=magento2.dev \
    PUBLIC_ADDRESS=http://magento_web.docker/ \
\
    FORCE_DATABASE_DROP=false \
    DATABASE_ARCHIVE_PATH=tools/assets/development/magentodb.sql.gz \
\
    DATABASE_NAME=magentodb \
    DATABASE_USER=magento \
    DATABASE_PASSWORD=magento \
    DATABASE_ROOT_PASSWORD=magento \
    DATABASE_HOST=database \
    ADDITIONAL_SETUP_SQL="" \
\
    ASSET_ARCHIVE_PATH=tools/assets/development/media.files.tgz \
    ASSET_DOWNLOAD_ENVIRONMENTS=development \
\
    FRONTEND_INSTALL_DIRECTORY=/app/tools/inviqa \
    FRONTEND_BUILD_DIRECTORY=/app/tools/inviqa \
    FRONTEND_BUILD_ACTION=build \
    GULP_BUILD_THEME_NAME="" \
\
    MAGENTO_MODE=production \
\
    FRONTEND_COMPILE_LANGUAGES=en_GB \
    MAGENTO_DEPENDENCY_INJECTION_COMPILE_COMMAND="bin/magento setup:di:compile" \
\
    MAGENTO_CRYPT_KEY="" \
\
    COMPOSER_CUSTOM_CONFIG_COMMAND=""
