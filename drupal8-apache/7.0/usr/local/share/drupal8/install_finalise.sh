#!/bin/bash

set -xe

# Download and install the assets when running the image
# (sad that we have to do that tho...)
if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi ;

# shellcheck source=./common_functions.sh
source "$DIR/common_functions.sh";

cd /app || exit 1;

# Download the static assets
set +e
is_hem_project
IS_HEM=$?
set -e
if [ "$IS_HEM" -eq 0 ]; then
  export HEM_RUN_ENV="${HEM_RUN_ENV:-local}"
  as_build "hem --non-interactive --skip-host-checks assets download"
  sh "$DIR/development/install_assets.sh"
fi

# Fix permissions for compiled CSS files, etc.
# But, only if the app directory is not via an NFS mountpoint, which doesn't
# allow chowning.
grep -q "/app nfs " /proc/mounts
IS_NFS=$?
if [ "$IS_NFS" -ne 0 ]; then
  chown -R www-data:www-data "/app/docroot/sites/default/files/"
fi

if [ -f "$DIR/install_finalise_custom.sh" ]; then
  bash "$DIR/install_finalise_custom.sh"
fi
