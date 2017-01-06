#!/bin/bash

set -xe

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi ;

for file in "${DIR}"/*/build.sh; do
  # shellcheck source=/dev/null
  bash "${file}"
done
