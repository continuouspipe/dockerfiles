#!/bin/bash

set -xe

source /usr/local/share/bootstrap/common_functions.sh

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi

cd /app || exit 1

function do_magento_cache_clean() {
  as_code_owner "php /app/bin/n98-magerun.phar cache:clean config" /app/public
}

function do_magento_system_setup() {
  as_code_owner "php /app/bin/n98-magerun.phar sys:setup:incremental -n" /app/public
}

function do_magento_reindex() {
  (as_code_owner "php /app/bin/n98-magerun.phar index:reindex:all" /app/public || echo "Failing indexing to the end, ignoring.") && echo "Indexing successful"
}

function do_magento_assets() {
  # Download the static assets
  set +e
  is_hem_project
  set -e
  IS_HEM=$?
  if [ "$IS_HEM" -eq 0 ]; then
    export HEM_RUN_ENV="${HEM_RUN_ENV:-local}"
    for asset_env in $ASSET_DOWNLOAD_ENVIRONMENTS; do
      as_build "hem --non-interactive --skip-host-checks assets download -e $asset_env"
    done
    bash "$DIR/development/install_assets.sh"
  fi
}

function do_magento_cache_flush() {
  # Flush magento cache
  as_code_owner "php bin/n98-magerun.phar cache:flush"
}

function do_magento_finalise_custom() {
  if [ -f "$DIR/install_magento_finalise_custom.sh" ]; then
    # shellcheck source=./install_magento_finalise_custom.sh
    source "$DIR/install_magento_finalise_custom.sh"
  fi
}

function do_magento_build_finalise() {
  do_magento_cache_clean
  do_magento_system_setup
  do_magento_reindex
  do_magento_assets
  do_magento_cache_flush
  do_magento_finalise_custom
}
