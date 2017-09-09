ARG FROM_TAG
FROM mysql:${FROM_TAG}

COPY ./docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/

MAINTAINER "Kieren Evans <kieren.evans+cp-dockerfiles@inviqa.com>"
