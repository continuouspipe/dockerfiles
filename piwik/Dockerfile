ARG PHP_VERSION
ARG FROM_TAG=latest
FROM quay.io/continuouspipe/php${PHP_VERSION}-apache:${FROM_TAG}

WORKDIR /app/web/piwik
RUN curl -L -O https://builds.piwik.org/latest.tar.gz && \
    tar --strip 1 -xzf latest.tar.gz && \
    rm latest.tar.gz

RUN chown -R build:www-data ./*
RUN chmod -R 0755 ./*
RUN chmod -R 0775 tmp \
    config
