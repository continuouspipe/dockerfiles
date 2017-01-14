#!/bin/bash
set -xe

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

# Install composer and npm dependencies
# shellcheck source=../install_magento.sh
bash "$DIR/../install_magento.sh";

do_magento_assets

bash "$DIR/install_database.sh"

replace_core_config_values

bash "$DIR/install_assets.sh"

if [ -f "$DIR/install_custom.sh" ]; then
  # shellcheck source=./install_custom.sh
  source "$DIR/install_custom.sh"
fi

