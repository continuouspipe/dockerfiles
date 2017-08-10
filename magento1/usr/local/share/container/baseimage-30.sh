#!/bin/bash

source /usr/local/share/magento1/magento_functions.sh

alias_function do_build do_magento_build_inner
do_build() {
  do_magento_build_inner
  do_magento_build
}

alias_function do_assets_apply_file_permissions do_magento_assets_apply_file_permissions_inner
do_assets_apply_file_permissions() {
  do_magento_assets_apply_file_permissions_inner
  if [ "${TASK}" == "start" ] && [ "${DEVELOPMENT_MODE}" == "false" ]; then
    # do_magento_build runs this, but if applied during do_start in non-dev,
    # this needs to be run
    do_magento_directory_permissions
  fi
}

alias_function do_development_start do_magento_development_start_inner
do_development_start() {
  do_magento_development_start_inner
  do_magento_development_start
}

alias_function do_templating do_magento_templating_inner
do_templating() {
  do_magento_templating
  do_magento_templating_inner
}

do_magento_development_start() {
  do_magento_build
  do_magento_development_build
}

alias_function do_setup do_magento_setup_inner
do_setup() {
  do_magento_setup_inner
  do_templating
  do_magento_setup
}
