#!/bin/bash
source /usr/local/share/spryker/spryker_functions.sh

alias_function do_build do_spryker_nginx_build_inner
do_build() {
  do_spryker_nginx_build_inner
  do_templating
  do_spryker_build
}

alias_function do_templating do_spryker_templating_inner
do_templating() {
  do_spryker_templating_inner
  do_spryker_vhosts
}

alias_function do_start do_spryker_start_inner
do_start() {
  do_spryker_config_create
  do_spryker_start_inner
}

alias_function do_development_start do_spryker_development_start_inner
do_development_start() {
  do_spryker_development_start_inner
  do_spryker_build
  do_spryker_install
  do_spryker_app_permissions
}

alias_function do_setup do_spryker_setup_inner
do_setup() {
  do_spryker_setup_inner
  do_templating
  do_spryker_build
  do_spryker_install
  do_spryker_migrate
}
