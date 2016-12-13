FROM ubuntu:16.04

MAINTAINER Kieren Evans <kieren.evans+cp-dockerfiles@inviqa.com>

RUN echo 'APT::Install-Recommends 0;' >> /etc/apt/apt.conf.d/01norecommends \
 && echo 'APT::Install-Suggests 0;' >> /etc/apt/apt.conf.d/01norecommends \
 && apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -s dist-upgrade | grep "^Inst" | \
      grep -i securi | awk -F " " '{print $2}' | \
      xargs apt-get -qq -y --no-install-recommends install \
 \
 # Install base packages \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    acl \
    apt-transport-https \
    ca-certificates \
    daemontools \
    cron \
    curl \
    git \
    net-tools \
    rsync \
    sudo \
    supervisor \
    unzip \
    vim.tiny \
    wget \
 \
 # Clean the image \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 \
 # Create the build user \
 && useradd --create-home --system build \
 \
 # Install confd for templating \
 && curl -sSL -o /usr/local/bin/confd \
    https://github.com/kelseyhightower/confd/releases/download/v0.11.0/confd-0.11.0-linux-amd64 \
 && chmod +x /usr/local/bin/confd

COPY ./etc/ /etc/
COPY ./usr/ /usr/

CMD ["/usr/local/bin/supervisor_start"]
