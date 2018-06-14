ARG FROM_TAG
FROM docker.elastic.co/elasticsearch/elasticsearch:${FROM_TAG}

USER root
RUN yum makecache fast && yum upgrade -y && yum clean all
USER elasticsearch
