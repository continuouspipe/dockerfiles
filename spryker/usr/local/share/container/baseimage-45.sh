#!/bin/bash
source /usr/local/share/spryker/spryker_functions.sh

alias_function do_build_permissions do_spryker_build_permissions_inner
do_build_permissions() {
  do_spryker_build_permissions_inner
  do_spryker_build
}

alias_function do_composer do_spryker_composer_inner
do_composer() {
  do_spryker_composer_inner
  do_spryker_app_permissions
  do_build_assets
  do_generate_files
}

alias_function do_templating do_spryker_templating_inner
do_templating() {
  do_spryker_templating
  do_spryker_templating_inner
}
