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
IS_CHOWN_FORBIDDEN="$(is_chown_forbidden)"
set -e

function do_magento_switch_web_writable_directories_to_code_owner() {
  if [ "$IS_CHOWN_FORBIDDEN" != 'true' ]; then
    chown -R "${CODE_OWNER}":"${CODE_GROUP}" pub/media pub/static var
  else
    chmod a+rw pub/media pub/static var
  fi
}

function do_magento_move_compiled_assets_away_from_codebase() {
  # Preserve compiled theme files across setup:upgrade calls.
  if [ -d pub/static/frontend/ ]; then
    mkdir /tmp/assets
    mv pub/static/frontend/ /tmp/assets/
  fi
}

function do_magento_setup_upgrade() {
  rm -rf var/generation/*
  redis-cli -h "$REDIS_HOST" -p "$REDIS_HOST_PORT" -n "$MAGENTO_REDIS_CACHE_DATABASE" "FLUSHDB"
  redis-cli -h "$REDIS_HOST" -p "$REDIS_HOST_PORT" -n "$MAGENTO_REDIS_FULL_PAGE_CACHE_DATABASE" "FLUSHDB"
  as_code_owner "bin/magento setup:upgrade"
}

function do_magento_move_compiled_assets_back_to_codebase() {
  if [ -d /tmp/assets/ ]; then
    mkdir -p pub/static/
    mv /tmp/assets/frontend/ pub/static/
    rm -rf /tmp/assets
  fi
}

function do_magento_dependency_injection_compilation() {
  # Compile the DIC if to be productionized
  if [ "$PRODUCTION_ENVIRONMENT" == 'true' ]; then
    as_code_owner "$MAGENTO_DEPENDENCY_INJECTION_COMPILE_COMMAND"
  fi
}

function do_magento_deploy_static_content() {
  # Compile static content if it's a production container.
  if [ "$MAGENTO_MODE" = "production" ]; then
    as_code_owner "bin/magento setup:static-content:deploy $FRONTEND_COMPILE_LANGUAGES"
  fi
}

function do_magento_reindex() {
  (as_code_owner "bin/magento indexer:reindex" || echo "Failing indexing to the end, ignoring.") && echo "Indexing successful"
}

# Download the static assets
set +e
IS_HEM="$(is_hem_project)"
set -e

function do_magento_assets_download() {
  if [ "$IS_HEM" == 'true' ]; then
    export HEM_RUN_ENV="${HEM_RUN_ENV:-local}"
    for asset_env in $ASSET_DOWNLOAD_ENVIRONMENTS; do
      as_build "hem --non-interactive --skip-host-checks assets download -e $asset_env"
    done
  fi
}

function do_magento_assets_install() {
  bash "$DIR/development/install_assets.sh"
}

function do_magento_cache_flush() {
  # Flush magento cache
  as_code_owner "bin/magento cache:flush"
}

function do_magento_create_web_writable_directories() {
  # Ensure the permissions are web writable for the assets and var folders, but only on filesystems that allow chown.
  if [ "$IS_CHOWN_FORBIDDEN" != 'true' ]; then
    chown -R "${APP_USER}:${APP_GROUP}" pub/media pub/static var
  fi
}

function do_magento_install_finalise_custom() {
  if [ -f "$DIR/install_magento_finalise_custom.sh" ]; then
    # shellcheck source=./install_magento_finalise_custom.sh
    source "$DIR/install_magento_finalise_custom.sh"
  fi
}

function do_magento_install_finalise() {
  do_magento_switch_web_writable_directories_to_code_owner
  do_magento_move_compiled_assets_away_from_codebase
  do_magento_setup_upgrade
  do_magento_move_compiled_assets_back_to_codebase
  do_magento_dependency_injection_compilation
  do_magento_deploy_static_content
  do_magento_reindex
  do_magento_assets_download
  do_magento_assets_install
  do_magento_cache_flush
  do_magento_create_web_writable_directories
  do_magento_install_finalise_custom
}
do_magento_install_finalise
