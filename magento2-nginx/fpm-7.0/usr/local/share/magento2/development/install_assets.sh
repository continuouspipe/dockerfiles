#!/bin/bash

set -xe

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi ;

source "$DIR/../common_functions.sh";

if [ -f tools/assets/development/media.files.tgz ]; then
  echo 'extracting media files'
  as_build "tar --no-same-owner --extract --gzip --file=tools/assets/development/media.files.tgz || exit 1"
fi
