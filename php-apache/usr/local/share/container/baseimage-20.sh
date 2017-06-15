#!/bin/bash

source /usr/local/share/assets/assets_functions.sh
source /usr/local/share/php/common_functions.sh
source /usr/local/share/php/apache_functions.sh

alias_function do_build do_php_apache_build_inner
do_build() {
  do_php_apache_build_inner
  do_build_permissions
  do_assets_all
  do_composer
}

alias_function do_start do_php_apache_start_inner
do_start() {
  do_assets_all
  do_apache
  do_php_apache_start_inner
}

alias_function do_development_start do_php_apache_development_start_inner
do_development_start() {
  do_php_apache_development_start_inner
  do_build_permissions
  do_composer
}
