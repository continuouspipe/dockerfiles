FROM makuk66/docker-solr:4.10.4

MAINTAINER Kieren Evans <kieren.evans+cp-dockerfiles@inviqa.com>

USER root

RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -s dist-upgrade | grep "^Inst" | \
      grep -i securi | awk -F " " '{print $2}' | \
      xargs apt-get -qq -y --no-install-recommends install \
 \
 # Clean the image \
 && apt-get autoremove -qq \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY ./usr/ /usr

CMD ["/bin/bash", "-c", "/usr/local/share/solr/startup.sh"]
