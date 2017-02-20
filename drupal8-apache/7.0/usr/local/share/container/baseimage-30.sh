#!/bin/bash

# This is intentionally left as drupal8_functions for the time being.
# If we need a different set of functions for Drupal 7, then we can load in a
# different functions file, and keep this main one the same.
source /usr/local/share/drupal/drupal8_functions.sh

set_drupal_version() {
  drush core-status drupal-version --format=list | cut -d"." -f 1
}

#####
# Tasks here happen during the bulding of the Dockerfile, and cannot rely on
# other services being available.
#####
alias_function do_build do_drupal_build_inner
do_build() {
  do_drupal_build_inner
  do_drupal_build
}

alias_function do_build do_drupal_development_build_inner
do_development_build() {
  do_drupal_development_build_inner
  do_drupal_development_build
}

#####
# Tasks here are executed once all other services are available, so it should
# be safe to to any tasks requiring databases, SOLR, etc.
#####
# alias_function do_setup do_drupal_setup_inner
# do_setup() {
#   do_drupal_setup_inner
# }

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