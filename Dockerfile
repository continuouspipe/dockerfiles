FROM quay.io/continuouspipe/ubuntu16.04:latest

 RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    bats \
    entr \
 \
 # Clean the image \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY ./tests/plan.sh /usr/local/share/container/plan.sh
COPY . /app
WORKDIR /app

CMD ["container", "watch_tests"]
