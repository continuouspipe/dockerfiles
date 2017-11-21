ARG FROM_TAG=latest
FROM quay.io/continuouspipe/ubuntu16.04:${FROM_TAG}

# Install node
ARG NODE_VERSION
ENV NODE_VERSION ${NODE_VERSION:-7.x}
ARG INSTALL_COMMON_PACKAGES
ENV INSTALL_COMMON_PACKAGES ${INSTALL_COMMON_PACKAGES:-true}
RUN curl -sL "https://deb.nodesource.com/setup_$NODE_VERSION" > /tmp/install-node.sh \
 && bash /tmp/install-node.sh \
 && apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    nodejs \
 \
 # Set up common NPM packages \
 && if [ "$INSTALL_COMMON_PACKAGES" = "true" ]; then \
      npm config set --global loglevel warn \
   && npm install --global \
      marked \
      node-gyp \
      gulp \
      \
      # Install node-sass's linux bindings \
   && npm rebuild node-sass; \
    fi \
 \
 # Clean the image \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
