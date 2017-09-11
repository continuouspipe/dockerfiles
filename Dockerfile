FROM quay.io/continuouspipe/ubuntu16.04:latest

MAINTAINER Kieren Evans <kieren.evans+cp-dockerfiles@inviqa.com>

RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    bats \
    entr \
 \
 # Clean the image \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 \
 # Install bats-mock package \
 && mkdir -p /usr/local/share/bats/ \
 && chown -R build:build /usr/local/share/bats/

COPY ./tests/plan.sh /usr/local/share/container/plan.sh
COPY ./tests/bats/helper.bash /usr/local/share/bats/
COPY . /app
WORKDIR /app

USER build
RUN git clone https://github.com/ztombol/bats-support.git /usr/local/share/bats/bats-support \
 && git clone https://github.com/ztombol/bats-assert.git /usr/local/share/bats/bats-assert \
 && git clone https://github.com/jasonkarns/bats-mock.git /usr/local/share/bats/bats-mock \
 && ( cd /usr/local/share/bats/bats-mock || exit 1; git apply /app/tests/bats-mock/0001-Patch-for-similar-space-splits-as-the-execution-plan.patch )
USER root

CMD ["container", "run_tests"]
