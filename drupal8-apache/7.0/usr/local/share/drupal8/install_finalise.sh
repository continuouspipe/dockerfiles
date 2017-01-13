#!/bin/bash

set -xe

# Download and install the assets when running the image
# (sad that we have to do that tho...)
if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi ;

source /usr/local/share/bootstrap/common_functions.sh

load_env

cd /app || exit 1;

SETTINGS_DIR="/app/docroot/sites/default"

# Download the static assets
set +e
is_hem_project
IS_HEM=$?
set -e
if [ "$IS_HEM" -eq 0 ]; then
  export HEM_RUN_ENV="${HEM_RUN_ENV:-local}"
  as_build "hem --non-interactive --skip-host-checks assets download"
  bash "$DIR/development/install_assets.sh"
fi

# Fix permissions for compiled CSS files, etc.
# But, only if the app directory is not via an NFS mountpoint, which doesn't
# allow chowning.
set +e
is_chown_supported
IS_CHOWN_SUPPORTED=$?
set -e
if [ "$IS_CHOWN_SUPPORTED" -ne 0 ] && [ -d "$SETTINGS_DIR/files/" ]; then
  chown -R "$APP_USER:$APP_GROUP" "$SETTINGS_DIR/files/"
fi

if [ -f "$DIR/install_finalise_custom.sh" ]; then
  bash "$DIR/install_finalise_custom.sh"
fi
