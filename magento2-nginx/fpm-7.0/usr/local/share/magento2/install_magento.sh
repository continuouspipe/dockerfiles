#!/bin/bash

set -xe

source common_functions.sh

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

  chmod -R go-w vendor
  chown -R www-data:www-data app pub var auth.json
  chmod +x bin/magento
fi

if [ -d "/app/tools/inviqa" ]; then
  if [ ! -d "/app/tools/inviqa/node_modules" ]; then
   as_build "npm install" "/app/tools/inviqa"
  fi
  as_build "gulp build" "/app/tools/inviqa"
fi
