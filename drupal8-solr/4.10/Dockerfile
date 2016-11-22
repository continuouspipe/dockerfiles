FROM quay.io/continuouspipe/solr:4.10_v2

MAINTAINER Kieren Evans <kieren.evans@inviqa.com>

ENV SOLR_CORE_NAME=d8

RUN mkdir -p /usr/local/share/solr/d8/data/tlog \
 && chown -R solr:solr /usr/local/share/solr/d8/data/

COPY ./usr/ /usr
