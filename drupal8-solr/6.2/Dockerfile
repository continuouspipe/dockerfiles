FROM quay.io/continuouspipe/solr:6.2_v1

MAINTAINER Kieren Evans <kieren.evans+cp-dockerfiles@inviqa.com>

ENV SOLR_CORE_NAME=d8
COPY ./docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d
COPY ./usr/ /usr
