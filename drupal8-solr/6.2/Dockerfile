FROM quay.io/continuouspipe/solr:6.2

MAINTAINER Kieren Evans <kieren.evans@inviqa.com>

ENV SOLR_CORE_NAME=d8
COPY ./docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d
COPY ./usr/ /usr
