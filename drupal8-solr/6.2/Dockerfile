FROM quay.io/continuouspipe/solr6:v1.0

MAINTAINER Kieren Evans <kieren.evans+cp-dockerfiles@inviqa.com>

ENV SOLR_CORE_NAME=d8
COPY ./docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d
COPY ./usr/ /usr
