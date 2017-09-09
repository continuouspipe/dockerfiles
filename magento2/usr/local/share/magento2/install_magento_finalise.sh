#!/bin/bash

set -e

source /usr/local/share/bootstrap/common_functions.sh

set -x

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi

cd /app || exit 1

set +e
IS_CHOWN_FORBIDDEN="$(run_return_boolean is_chown_forbidden)"
set -e

if [ "$IS_CHOWN_FORBIDDEN" != 'true' ]; then
  chown -R "${CODE_OWNER}":"${CODE_GROUP}" pub/media pub/static var
else
  chmod a+rw pub/media pub/static var
fi

# Preserve compiled theme files across setup:upgrade calls.
if [ -d pub/static/frontend/ ]; then
  mkdir /tmp/assets
  mv pub/static/frontend/ /tmp/assets/
fi

rm -rf var/generation/*
redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" -n "$MAGENTO_REDIS_CACHE_DATABASE" "FLUSHDB"
redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" -n "$MAGENTO_REDIS_FULL_PAGE_CACHE_DATABASE" "FLUSHDB"
as_code_owner "bin/magento setup:upgrade"

if [ -d /tmp/assets/ ]; then
  mkdir -p pub/static/
  mv /tmp/assets/frontend/ pub/static/
  rm -rf /tmp/assets
fi

# Compile the DIC if to be productionized
if [ "$PRODUCTION_ENVIRONMENT" == 'true' ]; then
  as_code_owner "$MAGENTO_DEPENDENCY_INJECTION_COMPILE_COMMAND"
fi

# Compile static content if it's a production container.
if [ "$MAGENTO_MODE" == "production" ]; then
  as_code_owner "bin/magento setup:static-content:deploy $FRONTEND_COMPILE_LANGUAGES"
fi

(as_code_owner "bin/magento indexer:reindex" || echo "Failing indexing to the end, ignoring.") && echo "Indexing successful"

# Download and install the assets when running the image
# (sad that we have to do that tho...)

# Download the static assets
if is_hem_project; then
  export HEM_RUN_ENV="${HEM_RUN_ENV:-local}"
  for asset_env in $ASSET_DOWNLOAD_ENVIRONMENTS; do
    as_build "hem --non-interactive --skip-host-checks assets download -e $asset_env"
  done
  bash "$DIR/development/install_assets.sh"
fi

# Flush magento cache
as_code_owner "bin/magento cache:flush"

# Ensure the permissions are web writable for the assets and var folders, but only on filesystems that allow chown.
if [ "$IS_CHOWN_FORBIDDEN" != 'true' ]; then
  chown -R "${APP_USER}:${APP_GROUP}" pub/media pub/static var
fi

if [ -f "$DIR/install_magento_finalise_custom.sh" ]; then
  # shellcheck source=./install_magento_finalise_custom.sh
  source "$DIR/install_magento_finalise_custom.sh"
fi
