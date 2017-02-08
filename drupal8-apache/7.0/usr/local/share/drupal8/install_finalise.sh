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

bash "$DIR/development/install_assets.sh"

# Fix permissions for compiled CSS files, etc.
# But, only if the app directory is not via an NFS mountpoint, which doesn't
# allow chowning.
set +e
is_chown_forbidden
IS_CHOWN_FORBIDDEN=$?
set -e
if [ "$IS_CHOWN_FORBIDDEN" -ne 0 ] && [ -d "$SETTINGS_DIR/files/" ]; then
  chown -R "$APP_USER:$APP_GROUP" "$SETTINGS_DIR/files/"
fi

if [ -f "$DIR/install_finalise_custom.sh" ]; then
  bash "$DIR/install_finalise_custom.sh"
fi
