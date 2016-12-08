#!/bin/bash

set -xe

source /usr/local/share/bootstrap/common_functions.sh

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi

cd /app || exit 1

# Preserve compiled theme files across setup:upgrade calls.
if [ -d pub/static/frontend/ ]; then
  mkdir /tmp/assets
  cp -pR pub/static/frontend/ /tmp/assets
fi

chown -R "${CODE_OWNER}":"${CODE_GROUP}" pub/media pub/static var

as_code_owner "bin/magento setup:upgrade"

if [ -d /tmp/assets/ ]; then
  mkdir -p pub/static/frontend/
  mv /tmp/assets/* pub/static/frontend/
  rm -rf /tmp/assets
fi

# Compile the DIC if to be productionized
if [ "$PRODUCTION_ENVIRONMENT" = "1" ]; then
  as_code_owner "$MAGENTO_DEPENDENCY_INJECTION_COMPILE_COMMAND"
fi

# Compile static content if it's a production container.
if [ "$MAGENTO_MODE" = "production" ]; then
  as_code_owner "bin/magento setup:static-content:deploy $FRONTEND_COMPILE_LANGUAGES"
fi

(as_code_owner "bin/magento indexer:reindex" || echo "Failing indexing to the end, ignoring.") && echo "Indexing successful"

# Download and install the assets when running the image
# (sad that we have to do that tho...)

# Download the static assets
set +e
is_hem_project
set -e
IS_HEM=$?
if [ "$IS_HEM" -eq 0 ]; then
  export HEM_RUN_ENV="${HEM_RUN_ENV:-local}"
  as_build "hem --non-interactive --skip-host-checks assets download"
  bash "$DIR/development/install_assets.sh"
fi

set +e
is_nfs
IS_NFS=$?
set -e

# Flush magento cache
as_code_owner "bin/magento cache:flush"

# Ensure the permissions are web writable for the assets and var folders, but only on filesystems that allow chown.
if [ "$IS_NFS" -ne 0 ]; then
  chown -R "${APP_USER}:${APP_GROUP}" pub/media pub/static var
fi

if [ -f "$DIR/install_magento_finalise_custom.sh" ]; then
  # shellcheck source=./install_magento_finalise_custom.sh
  source "$DIR/install_magento_finalise_custom.sh"
fi
