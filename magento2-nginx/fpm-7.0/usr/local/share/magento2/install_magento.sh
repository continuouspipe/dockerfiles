#!/bin/sh

cd /app;

if [ ! -f "/app/app/etc/env.php" ]; then
  cp /app/tools/docker/magento/env.php /app/app/etc/env.php
  cp /app/tools/docker/magento/config.php /app/app/etc/config.php
fi

if [ ! -d "/app/vendor" ]; then
  sudo -u build composer config repositories.magento composer https://repo.magento.com/
  sudo -u build composer config http-basic.repo.magento.com $MAGENTO_USERNAME $MAGENTO_PASSWORD
  sudo -u build composer config http-basic.toran.inviqa.com $TORAN_USERNAME $TORAN_PASSWORD
  sudo -u build composer config github-oauth.github.com $GITHUB_TOKEN

  # do not use optimize-autoloader parameter yet, according to github, Mage2 has issues with it
  sudo -u build composer install --no-interaction
  sudo -u build composer clear-cache

  chown -R go-w vendor
  chown -R www-data:www-data app pub var auth.json
  chmod +x bin/magento
fi

if [ -d "/app/tools/inviqa" ]; then
  cd /app/tools/inviqa
  if [ ! -d "node_modules" ]; then
    sudo -u build npm install
  fi
  sudo -u build gulp build
fi
