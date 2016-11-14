FROM makuk66/docker-solr:4.10.4

MAINTAINER Kieren Evans <kieren.evans@inviqa.com>

COPY ./usr/ /usr

CMD ["/bin/bash", "-c", "/opt/solr/bin/solr -f -s /usr/local/share/solr/"]
