#!/bin/bash

alias_function do_build do_drupal8_build_inner
do_build() {
  do_drupal8_build_inner
  do_drupal8_install
}

alias_function do_development_start do_drupal8_development_start_inner
do_development_start() {
  do_drupal8_development_start_inner
  bash /usr/local/share/drupal8/development/install.sh
}

do_composer() {
  # disable original composer in image hierarchy till install ported
  :
}

do_drupal8_install() {
  bash /usr/local/share/drupal8/install.sh
  bash /usr/local/share/drupal8/install_finalise.sh
}
