#!/bin/bash

set -xe

# Download and install the assets when running the image
# (sad that we have to do that tho...)
if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi ;

source "$DIR/common_functions.sh";

cd /app || exit 1;

# Download the static assets
$(is_hem_project)
IS_HEM=$?
if [ "$IS_HEM" -eq 0 ]; then
  export HEM_RUN_ENV="${HEM_RUN_ENV:-local}"
  as_build "hem --non-interactive --skip-host-checks assets download"
  sh "$DIR/development/install_assets.sh"
fi
