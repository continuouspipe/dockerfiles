#!/bin/bash
set -xe

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi

source /usr/local/share/bootstrap/common_functions.sh
source /usr/local/share/php/common_functions.sh

cd /app || exit 1;

run_composer

cd /app/docroot || exit 1;

if [ -f "$DIR/install_custom.sh" ]; then
  bash "$DIR/install_custom.sh"
fi
