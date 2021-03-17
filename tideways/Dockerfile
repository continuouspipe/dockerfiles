ARG FROM_TAG=latest
FROM quay.io/continuouspipe/ubuntu16.04:${FROM_TAG}

RUN echo 'deb https://packages.tideways.com/apt-packages-main any-version main' > /etc/apt/sources.list.d/tideways.list \
 && curl -L -sS https://packages.tideways.com/key.gpg | apt-key add - \
 && apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    tideways-daemon \
 \
 # Clean the image \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY ./etc/ /etc/
COPY ./usr/ /usr/
