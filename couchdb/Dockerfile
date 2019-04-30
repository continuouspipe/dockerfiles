ARG FROM_TAG
FROM couchdb:${FROM_TAG}

ARG FROM_TAG
RUN if [ "$FROM_TAG" = "1.6" ]; then \
    echo "deb http://deb.debian.org/debian/ jessie main" > /etc/apt/sources.list \
    && echo "deb http://security.debian.org/ jessie/updates main" >> /etc/apt/sources.list \
    && echo "Acquire::Check-Valid-Until false;" >> /etc/apt/apt.conf.d/10-nocheckvalid \
    && echo 'Package: *\nPin: origin "archive.debian.org"\nPin-Priority: 500' >> /etc/apt/preferences.d/10-archive-pin; \
 fi \
 && apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -s dist-upgrade | grep "^Inst" | \
      grep -i securi | awk -F " " '{print $2}' | \
      xargs apt-get -qq -y --no-install-recommends install \
 \
 # Clean the image \
 && apt-get autoremove -qq \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
