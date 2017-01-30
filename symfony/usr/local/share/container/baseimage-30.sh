#!/bin/bash

source /usr/local/share/symfony/symfony_functions.sh

alias_function do_build_permissions do_symfony_build_permissions_inner
do_build_permissions() {
  do_symfony_build
  do_symfony_build_permissions_inner
}

alias_function do_composer do_symfony_composer_inner
do_composer() {
  do_symfony_composer_inner
  do_symfony_app_permissions
}
