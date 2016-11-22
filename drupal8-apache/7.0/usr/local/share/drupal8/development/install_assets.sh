#!/bin/bash

set -xe

# install DB and assets
if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi ;

source /usr/local/share/bootstrap/common_functions.sh

if [ -f tools/assets/development/media.files.tgz ]; then
  echo 'extracting media files'
  as_build "tar --no-same-owner --extract --gzip --file=tools/assets/development/media.files.tgz || exit 1"
fi
