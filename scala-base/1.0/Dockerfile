FROM quay.io/continuouspipe/ubuntu:16.04_v1

MAINTAINER Sarunas Valaskevicius <svalaskevicius+cp-dockerfiles@inviqa.com>

# based on java:8 and https://github.com/hseeberger/scala-sbt images

ENV SBT_VERSION 0.13.13

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV JAVA_VERSION 8u111
ENV JAVA_DEBIAN_VERSION 8u111-b14-2ubuntu0.16.04.2
ENV CA_CERTIFICATES_JAVA_VERSION 20160321

ENV LANG C.UTF-8

# Install Java
RUN set -x \
  && apt-get update && apt-get install -y --no-install-recommends \
		bzip2 \
		unzip \
		xz-utils \
  && { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home \
  && apt-get update \
	&& apt-get install -y \
		openjdk-8-jdk="$JAVA_DEBIAN_VERSION" \
		openjdk-8-jre-headless="$JAVA_DEBIAN_VERSION" \
		ca-certificates-java="$CA_CERTIFICATES_JAVA_VERSION" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ] \
  && /var/lib/dpkg/info/ca-certificates-java.postinst configure \
 \
 # Install sbt \
  && curl -L -o sbt-$SBT_VERSION.deb http://dl.bintray.com/sbt/debian/sbt-$SBT_VERSION.deb \
  && dpkg -i sbt-$SBT_VERSION.deb \
  && rm sbt-$SBT_VERSION.deb \
  && apt-get install -y sbt \
  && sbt sbtVersion \
 \
 # Clean the image \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Define working directory
WORKDIR /root

