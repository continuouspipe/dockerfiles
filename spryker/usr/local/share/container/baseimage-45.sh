#!/bin/bash
source /usr/local/share/spryker/spryker_functions.sh

alias_function do_build_permissions do_spryker_build_permissions_inner
do_build_permissions() {
  do_spryker_build_permissions_inner
  do_spryker_build
}

alias_function do_build do_spryker_nginx_build_inner
do_build() {
  do_spryker_nginx_build_inner
  do_templating
  do_generate_files
  do_build_assets
  do_spryker_app_permissions
}

alias_function do_templating do_spryker_templating_inner
do_templating() {
  do_spryker_templating_inner
  do_spryker_vhosts
}

alias_function do_setup do_spryker_setup_inner
do_setup() {
  do_spryker_setup_inner
  do_spryker_install
}
