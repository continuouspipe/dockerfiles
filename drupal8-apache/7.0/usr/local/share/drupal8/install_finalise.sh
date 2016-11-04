#!/bin/bash

set -xe

cd /app || exit 1;

source ./common_functions.sh

# Download and install the assets when running the image
# (sad that we have to do that tho...)
if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi ;

# Download the static assets
export HEM_RUN_ENV="${HEM_RUN_ENV:-local}"
as_build "hem --non-interactive --skip-host-checks assets download"
sh "$DIR/development/install_assets.sh"
