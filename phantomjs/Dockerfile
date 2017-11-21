ARG FROM_TAG=latest
FROM quay.io/continuouspipe/ubuntu16.04:${FROM_TAG}

ARG PHANTOMJS_VERSION=2.1.1

RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
   bzip2 \
   fontconfig \
  \
 # Clean the image \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
  \
 && PHANTOM_JS=phantomjs-${PHANTOMJS_VERSION}-linux-x86_64 \
 && wget --directory-prefix=/usr/local/src "https://bitbucket.org/ariya/phantomjs/downloads/${PHANTOM_JS}.tar.bz2" \
 && tar -jxvf "/usr/local/src/${PHANTOM_JS}.tar.bz2" --directory /usr/local/src \
 && mv "/usr/local/src/${PHANTOM_JS}/bin/phantomjs" /usr/local/bin/ \
 && rm -rf "/usr/local/src/${PHANTOMJS}*" \
 && useradd phantomjs

COPY ./etc/ /etc/

EXPOSE 4444
