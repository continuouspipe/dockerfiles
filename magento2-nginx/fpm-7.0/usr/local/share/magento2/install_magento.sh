#!/bin/bash

set -xe

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi ;

source /usr/local/share/bootstrap/common_functions.sh

cd /app || exit 1;

set +e
is_nfs
IS_NFS=$?
set -e

if [ ! -f "/app/app/etc/env.php" ]; then
  cp /app/tools/docker/magento/env.php /app/app/etc/env.php
  cp /app/tools/docker/magento/config.php /app/app/etc/config.php
fi

if [ ! -d "/app/vendor" ] || [ ! -f "/app/vendor/autoload.php" ]; then
  as_build "composer config repositories.magento composer https://repo.magento.com/"
  as_build "composer config http-basic.repo.magento.com '$MAGENTO_USERNAME' '$MAGENTO_PASSWORD'"
  as_build "composer config http-basic.toran.inviqa.com '$TORAN_USERNAME' '$TORAN_PASSWORD'"
  as_build "composer config github-oauth.github.com '$GITHUB_TOKEN'"

  # do not use optimize-autoloader parameter yet, according to github, Mage2 has issues with it
  as_build "composer install --no-interaction"
  as_build "composer clear-cache"

  chmod 600 auth.json
  chmod -R go-w vendor
  chmod +x bin/magento

  if [ "$IS_NFS" -ne 0 ]; then
    chown -R www-data:www-data pub/media pub/static var
  fi
fi

if [ -d "/app/tools/inviqa" ]; then
  if [ -d "/app/pub/static/frontend/" ] && [ "$IS_NFS" -ne 0 ]; then
    chown -R build:build /app/pub/static/frontend/
  fi

  if [ ! -d "/app/tools/inviqa/node_modules" ]; then
   as_build "npm install" "/app/tools/inviqa"
  fi
  if [ -z "$GULP_BUILD_THEME_NAME" ]; then
    as_build "gulp build" "/app/tools/inviqa"
  else
    as_build "gulp build --theme='$GULP_BUILD_THEME_NAME'" "/app/tools/inviqa"
  fi

  if [ -d "/app/pub/static/frontend/" ] && [ "$IS_NFS" -ne 0 ]; then
    chown -R www-data:www-data /app/pub/static/frontend/
  fi
fi
