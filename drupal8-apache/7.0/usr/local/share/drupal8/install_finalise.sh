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

cd /app || exit 1;

SETTINGS_DIR="/app/docroot/sites/default"

chmod u+w "$SETTINGS_DIR" || true
mkdir -p "$SETTINGS_DIR/files/"

# Install a database if there isn't one yet
set +e
as_build "drush sql-query 'SHOW TABLES;' | grep -v cache | grep -q ''" /app/docroot
HAS_CURRENT_TABLES=$?
set -e
if [ "$HAS_CURRENT_TABLES" -ne 0 ]; then
  chown build:build "$SETTINGS_DIR/files/"
  as_build "echo 'y' | drush site-install lightning" "/app/docroot"
  chown -R www-data:www-data "$SETTINGS_DIR/files/"
fi

chmod a-w "$SETTINGS_DIR"

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
is_nfs
IS_NFS=$?
set -e
if [ "$IS_NFS" -ne 0 ]; then
  chown -R www-data:www-data "$SETTINGS_DIR/files/"
fi

as_build "drush cache-rebuild" "/app/docroot"

if [ -f "$DIR/install_finalise_custom.sh" ]; then
  bash "$DIR/install_finalise_custom.sh"
fi
