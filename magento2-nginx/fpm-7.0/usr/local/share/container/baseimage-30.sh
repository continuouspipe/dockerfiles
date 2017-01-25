#!/bin/bash

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
  do_magento2_templating_inner
}

do_composer() {
  # disable original composer in image hierarchy till install_magento ported
  :
}

do_magento2_install() {
  bash /usr/local/share/magento2/install_magento.sh
}

do_setup() {
  do_magento2_setup
}

do_magento2_setup() {
  bash /usr/local/share/magento2/install_magento_finalise.sh
}

do_magento2_development_start()
{
  bash /usr/local/share/magento2/development/install.sh
  do_magento2_setup
}
