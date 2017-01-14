#!/bin/bash

source /usr/local/share/magento1/magento_function.sh

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

alias_function do_templating do_magento_templating_inner
do_templating() {
  mkdir -p /home/build/.hem/gems/
  chown -R build:build /home/build/.hem/
  do_magento_templating_inner
}

# alias_function do_composer do_magento_composer_inner
# do_composer() {
#   do_magento_composer_inner
# }

do_magento_install() {
  do_magento_build
}

do_magento_development_start() {
  bash /usr/local/share/magento/development/install.sh
  bash /usr/local/share/magento1/install_magento_finalise.sh
}
