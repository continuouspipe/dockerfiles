#!/bin/bash

set -xe

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi ;

source "$DIR/common_functions.sh"

cd /app || exit 1;

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
  chown -R www-data:www-data pub/media pub/static var
fi

if [ -d "/app/tools/inviqa" ]; then
  if [ -d "/app/pub/static/frontend/" ]; then
    chown -R build:build /app/pub/static/frontend/
  fi

  if [ ! -d "/app/tools/inviqa/node_modules" ]; then
   as_build "npm install" "/app/tools/inviqa"
  fi
  as_build "gulp build" "/app/tools/inviqa"

  if [ -d "/app/pub/static/frontend/" ]; then
    chown -R www-data:www-data /app/pub/static/frontend/
  fi
fi
