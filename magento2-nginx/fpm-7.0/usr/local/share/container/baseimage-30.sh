#!/bin/bash

source /usr/local/share/magento2/magento_functions.sh

alias_function do_build do_magento2_build_inner
do_build() {
  do_magento2_build_inner
  do_magento2_install
}

alias_function do_development_start do_magento2_development_start_inner
do_development_start() {
  do_magento2_development_start_inner
  do_magento2_development_start
}

alias_function do_templating do_magento2_templating_inner
do_templating() {
  mkdir -p /app/app/etc/
  mkdir -p /home/build/.hem/gems/
  chown -R build:build /home/build/.hem/
  do_magento2_templating_inner
}

alias_function do_composer do_magento2_composer_inner
do_composer() {
  do_magento2_composer
  do_magento2_composer_inner
  do_composer_post_install
}

do_magento2_install() {
  do_magento2_build
}

do_setup() {
  do_magento2_setup
}

do_magento2_development_start()
{
  do_magento2_install
  do_magento2_development_build
  do_magento2_setup
}

do_magento()
{
  set +x
  if [ "$#" -gt 0 ]; then
    as_app_user "./bin/magento $(printf "%q " "$@")"
  else
    as_app_user "./bin/magento"
  fi
}
