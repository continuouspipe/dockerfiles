ARG FROM_TAG
FROM elasticsearch:${FROM_TAG}

MAINTAINER "Kieren Evans <kieren.evans+cp-dockerfiles@inviqa.com>"

RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -s dist-upgrade | grep "^Inst" | \
      grep -i securi | awk -F " " '{print $2}' | \
      xargs apt-get -qq -y --no-install-recommends install \
 \
 # Clean the image \
 && apt-get autoremove -qq \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
