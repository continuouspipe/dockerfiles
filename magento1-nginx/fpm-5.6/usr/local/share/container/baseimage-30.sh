#!/bin/bash

alias_function do_build do_magento_build_inner
do_build() {
  do_magento_build_inner
  do_magento_install
}

alias_function do_development_start do_magento_development_start_inner
do_development_start() {
  do_magento_development_start_inner
  do_magento_development_start
}

do_composer() {
  # disable original composer in image hierarchy till install ported
  :
}

do_magento_install() {
  bash /usr/local/share/magento1/install_magento.sh
  bash /usr/local/share/magento1/install_magento_finalise.sh
}

do_magento_development_start() {
  bash /usr/local/share/magento/development/install.sh
}
