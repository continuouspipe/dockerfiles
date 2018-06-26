FROM quay.io/continuouspipe/ubuntu16.04:stable

RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    colordiff \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY ./compare.sh /app/compare.sh
COPY ./exclusions.txt /app/exclusions.txt
