#!/bin/bash

source /usr/local/share/drupal8/drupal8_functions.sh

#####
# Tasks here happen during the bulding of the Dockerfile, and cannot rely on
# other services being available.
#####
alias_function do_build do_drupal8_build_inner
do_build() {
  do_drupal8_build_inner
  do_drupal8_build
}

#####
# Tasks here are executed once all other services are available, so it should
# be safe to to any tasks requiring databases, SOLR, etc.
#####
# alias_function do_setup do_drupal8_setup_inner
# do_setup() {
#   do_drupal8_setup_inner
# }

#####
# Tasks here are run when the container is started, and all services should be
# available.
####
# alias_function do_start do_drupal8_start_inner
# do_start() {
#   do_drupal8_start_inner
# }
