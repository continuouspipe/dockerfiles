FROM ubuntu:16.04

RUN echo 'APT::Install-Recommends 0;' >> /etc/apt/apt.conf.d/01norecommends \
 && echo 'APT::Install-Suggests 0;' >> /etc/apt/apt.conf.d/01norecommends \
 && apt-get update -qq \
 && apt-get install -qqy \
    vim.tiny \
    curl \
    wget \
    net-tools \
    ca-certificates \
    unzip \
    supervisor \
    sudo \
    git \
    apt-transport-https \
    daemontools \
 && apt-get auto-remove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \

 && curl -sSL -o /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.11.0/confd-0.11.0-linux-amd64 \
 && chmod +x /usr/local/bin/confd

COPY etc/ /etc/
COPY start.sh /start.sh

CMD ["/start.sh"]
