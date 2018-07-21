#!/bin/bash

source /usr/local/share/database/database_functions.sh
source /usr/local/share/assets/assets_functions.sh
source /usr/local/share/php/common_functions.sh
source /usr/local/share/php/webserver_functions.sh

alias_function do_build do_php_build_inner
do_build() {
  do_php_build_inner
  do_build_permissions
  do_assets_all
  do_composer
}

alias_function do_start do_php_web_start_inner
do_start() {
  if [ "${DEVELOPMENT_MODE}" == "false" ]; then
    do_assets_all
  fi
  do_webserver
  do_php_web_start_inner
}

alias_function do_development_start do_php_development_start_inner
do_development_start() {
  do_php_development_start_inner
  do_build_permissions
  do_assets_all
  do_composer
}

alias_function do_setup do_php_setup_inner
do_setup() {
  do_php_setup_inner
  ASSETS_FILES_ENABLED="false" do_assets_all
}
