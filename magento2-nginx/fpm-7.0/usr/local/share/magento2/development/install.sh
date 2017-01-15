#!/bin/bash
set -e

mkdir -p /home/build/.hem/gems/ && chown -R build:build /home/build/.hem/

# Ensure the hem settings files exists by running confd before continuing
source /usr/local/share/bootstrap/setup.sh
source /usr/local/share/bootstrap/run_confd.sh

# install DB and assets
if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi

source /usr/local/share/bootstrap/common_functions.sh
# shellcheck source=./replace_core_config_values.sh
source "$DIR/replace_core_config_values.sh"

function do_magento_install() {
  # Install composer and npm dependencies
  # shellcheck source=../install_magento.sh
  bash "$DIR/../install_magento.sh";
}

set -x
set +e
IS_HEM="$(is_hem_project)"
set -e

function do_magento_assets_download() {
  if [ "$IS_HEM" == 'true' ]; then
    # Run HEM
    export HEM_RUN_ENV="${HEM_RUN_ENV:-local}"
    for asset_env in $ASSET_DOWNLOAD_ENVIRONMENTS; do
      as_build "hem --non-interactive --skip-host-checks assets download -e $asset_env"
    done
  fi
}

function do_magento_database_install() {
  bash "$DIR/install_database.sh"
}

function do_replace_core_config_values() {
  replace_core_config_values
}

function do_magento_assets_install() {
  bash "$DIR/install_assets.sh"
}

function do_magento_install_development_custom() {
  if [ -f "$DIR/install_custom.sh" ]; then
    # shellcheck source=./install_custom.sh
    source "$DIR/install_custom.sh"
  fi
}
