#!/bin/bash

set -xe

source /usr/local/share/bootstrap/common_functions.sh

# install assets
if [ -f tools/assets/development/media.files.tgz ]; then
  echo 'extracting media files'
  as_build "tar --no-same-owner --extract --gzip --file=tools/assets/development/media.files.tgz || exit 1"
fi
