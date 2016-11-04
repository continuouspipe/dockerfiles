#!/bin/bash

set -xe

cd /app || exit 1;

source ./common_functions.sh

if [ ! -f /app/docroot/sites/default/settings.php ]; then
  cp /app/tools/docker/config/settings.php /app/docroot/sites/default/
fi

if [ ! -f /app/docroot/sites/default/services.yml ]; then
  SOURCE_FILE="/app/docroot/sites/default/default.services.yml"
  if [ -f /app/tools/docker/config/services.yml ]; then
    SOURCE_FILE="/app/tools/docker/config/services.yml"
  fi

  cp "$SOURCE_FILE"  /app/docroot/sites/default/services.yml
fi

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
