ARG FROM_TAG=latest
FROM quay.io/continuouspipe/ubuntu16.04:${FROM_TAG}

# based on java:8 and https://github.com/hseeberger/scala-sbt images

ENV SBT_VERSION 0.13.13

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

ENV LANG C.UTF-8

# Install Java
RUN set -x \
  && apt-get update && apt-get install -y --no-install-recommends \
		bzip2 \
		unzip \
		xz-utils \
  && apt-get update \
	&& apt-get install -y openjdk-8-jdk openjdk-8-jre-headless ca-certificates-java \
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
 && rm -rf /var/lib/apt/lists/* \
 && mkdir /app

# Define working directory
WORKDIR /app
