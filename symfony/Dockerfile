ARG PHP_VERSION
ARG WEB_SERVER
ARG FROM_TAG=latest
FROM quay.io/continuouspipe/php${PHP_VERSION}-${WEB_SERVER}:${FROM_TAG}

MAINTAINER Kieren Evans <kieren.evans+cp-dockerfiles@inviqa.com>

COPY ./usr/ /usr
