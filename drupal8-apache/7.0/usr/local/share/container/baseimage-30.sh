#!/bin/bash

alias_function do_build do_drupal8_build_inner
do_build() {
  do_drupal8_build_inner
  do_drupal8_install
}

alias_function do_development_start do_drupal8_development_start_inner
do_development_start() {
  do_drupal8_development_start_inner
  do_drupal8_development_start
}

alias_function do_templating do_drupal8_templating_inner
do_templating() {
  mkdir -p /app/docroot/sites/default/
  do_drupal8_templating_inner
}

do_composer() {
  # disable original composer in image hierarchy till install ported
  :
}

do_drupal8_install() {
  bash /usr/local/share/drupal8/install.sh
}

do_drupal8_development_start() {
  bash /usr/local/share/drupal8/development/install.sh
  do_drupal8_setup
}

do_setup() {
  do_drupal8_setup
}

do_drupal8_setup() {
  bash /usr/local/share/drupal8/install_finalise.sh
}
