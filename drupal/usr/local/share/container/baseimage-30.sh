#!/bin/bash

source /usr/local/share/drupal/drupal_functions.sh

#####
# Tasks here happen during the bulding of the Dockerfile, and cannot rely on
# other services being available.
#####
alias_function do_build do_drupal_build_inner
do_build() {
  do_drupal_build_inner
  do_drupal_build
}

#####
# Tasks here are run when the container is started, and all services should be
# available.
####
alias_function do_start do_drupal_start_inner
do_start() {
  do_drupal_start_inner
  do_drupal_start
}

alias_function do_development_start do_drupal_development_start_inner
do_development_start() {
  do_drupal_development_start_inner
  do_drupal_development_start
}

alias_function do_setup do_drupal_setup_inner
do_setup() {
  do_drupal_setup_inner
  do_drupal_install
  do_drupal_legacy_install_script
  do_drupal_legacy_install_finalise_script
}
