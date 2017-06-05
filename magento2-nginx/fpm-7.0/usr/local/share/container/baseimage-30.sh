#!/bin/bash

alias_function do_build do_magento2_build_inner
do_build() {
  do_magento2_build_inner
  if [ "$IMAGE_VERSION" -ge 2 ]; then
    do_magento2_build
  else
    do_magento2_install
  fi
}

if [ "$IMAGE_VERSION" -lt 2 ]; then
  alias_function do_development_start do_magento2_development_start_inner
fi
do_development_start() {
  if [ "$IMAGE_VERSION" -ge 2 ]; then
    do_php_nginx_development_start_inner
    do_composer
    do_magento2_development_build
  else
    do_magento2_development_start_inner
    do_magento2_development_start
  fi
}

alias_function do_templating do_magento2_templating_inner
do_templating() {
  if [ "$IMAGE_VERSION" -ge 2 ]; then
    do_magento2_templating
  else
    mkdir -p /app/app/etc/
  fi
  do_magento2_templating_inner
}

if [ "$IMAGE_VERSION" -ge 2 ]; then
  alias_function do_composer do_magento2_composer_inner
  do_composer() {
    do_composer_config
    do_magento2_composer_inner
    do_composer_post_install
  }
else
  do_composer() {
    # disable original composer in image hierarchy till install_magento ported
    :
  }
fi

if [ "$IMAGE_VERSION" -lt 2 ]; then
  do_magento2_install() {
    bash /usr/local/share/magento2/install_magento.sh
  }
fi

do_setup() {
  if [ "$IMAGE_VERSION" -ge 2 ]; then
    do_templating
  fi
  do_magento2_setup
}

if [ "$IMAGE_VERSION" -lt 2 ]; then
  do_magento2_setup() {
    bash /usr/local/share/magento2/install_magento_finalise.sh
  }

  do_magento2_development_start()
  {
    bash /usr/local/share/magento2/development/install.sh
    do_magento2_setup
  }
fi

do_magento()
{
  set +x
  if [ "$#" -gt 0 ]; then
    as_app_user "./bin/magento $(printf "%q " "$@")"
  else
    as_app_user "./bin/magento"
  fi
}

if [ "$IMAGE_VERSION" -ge 2 ]; then
  source /usr/local/share/magento2/magento_functions.sh
fi
