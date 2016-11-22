FROM makuk66/docker-solr:4.10.4

MAINTAINER Kieren Evans <kieren.evans+cp-dockerfiles@inviqa.com>

USER root

COPY ./usr/ /usr

CMD ["/bin/bash", "-c", "/usr/local/share/solr/startup.sh"]
