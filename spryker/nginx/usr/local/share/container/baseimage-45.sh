#!/bin/bash
source /usr/local/share/spryker/spryker_functions.sh

alias_function do_symfony_build do_spryker_symfony_build_inner
do_build_permissions() {
  do_spryker_build
  do_spryker_symfony_build_inner
}
