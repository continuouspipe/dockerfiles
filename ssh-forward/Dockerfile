ARG FROM_TAG=latest
FROM quay.io/continuouspipe/ubuntu16.04:${FROM_TAG}

RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    ssh \
 \
 # Clean the image \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir /var/run/sshd \
 && useradd --create-home forward \
 && echo "ForceCommand echo 'This account can only be used for ssh port forwarding'" >> /etc/ssh/sshd_config \
 && echo "GatewayPorts yes" >> /etc/ssh/sshd_config

COPY ./etc/ /etc
COPY ./usr/ /usr

EXPOSE 22
