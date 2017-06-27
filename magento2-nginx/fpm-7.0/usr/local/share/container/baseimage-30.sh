#!/bin/bash

if [ "$IMAGE_VERSION" -ge 2 ]; then
  source /usr/local/share/magento2/magento_functions.sh

  alias_function do_build do_magento2_build_inner
  do_build() {
    do_magento2_build_inner
    PRODUCTION_ENVIRONMENT="$PRODUCTION_ENVIRONMENT" MAGENTO_MODE="$BUILD_MAGENTO_MODE" DEVELOPMENT_MODE="$BUILD_DEVELOPMENT_MODE" do_magento2_build
  }

  do_development_start() {
    do_php_nginx_development_start_inner
    do_composer
    do_magento2_development_build
  }

  alias_function do_templating do_magento2_templating_inner
  do_templating() {
    do_magento2_templating
    do_magento2_templating_inner
  }

  alias_function do_composer do_magento2_composer_inner
  do_composer() {
    do_composer_config
    do_magento2_composer_inner
    do_composer_post_install
  }

  do_setup() {
    do_templating
    do_magento2_setup
  }
else
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

  do_magento2_development_start() {
    bash /usr/local/share/magento2/development/install.sh
    do_magento2_setup
  }
fi


do_magento() {
  set +x
  if [ "$#" -gt 0 ]; then
    as_app_user "./bin/magento $(printf "%q " "$@")"
  else
    as_app_user "./bin/magento"
  fi
}
