FROM quay.io/inviqa_images/solr:4.10

MAINTAINER Kieren Evans <kieren.evans@inviqa.com>

COPY ./usr/ /usr

USER root

RUN mkdir -p /usr/local/share/solr/d8/data/tlog \
 && chown -R solr:solr /usr/local/share/solr/d8/data/

USER solr
