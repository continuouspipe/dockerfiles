ARG FROM_TAG=latest
FROM quay.io/continuouspipe/solr4:${FROM_TAG}

ENV SOLR_CORE_NAME=d8

RUN mkdir -p /usr/local/share/solr/d8/data/tlog \
 && chown -R solr:solr /usr/local/share/solr/d8/data/

COPY ./usr/ /usr
