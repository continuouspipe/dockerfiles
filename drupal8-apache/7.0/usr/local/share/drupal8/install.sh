#!/bin/bash
set -xe

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi ;

source "$DIR/common_functions.sh";

cd /app || exit 1;

if [ ! -d "/app/vendor" ] || [ ! -f "/app/vendor/autoload.php" ]; then
  as_build "composer config github-oauth.github.com '$GITHUB_TOKEN'"

  as_build "composer install --optimize-autoloader --no-interaction"
  as_build "composer clear-cache"

  chmod -R go-w vendor
fi

cd /app/docroot || exit 1;

if [ ! -d /app/docroot/sites/default ]; then
  as_build "drush site-install lightning -vvv"
fi

if [ ! -f /app/docroot/sites/default/settings.php ]; then
  mkdir -p /app/docroot/sites/default/
  cp /app/tools/docker/config/settings.php /app/docroot/sites/default/settings.php
  chmod go-w /app/docroot/sites/default/settings.php
fi

if [ ! -f /app/docroot/sites/default/services.yml ]; then
  SOURCE_FILE="/app/docroot/sites/default/default.services.yml"
  if [ -f /app/tools/docker/config/services.yml ]; then
    SOURCE_FILE="/app/tools/docker/config/services.yml"
  fi

  cp "$SOURCE_FILE"  /app/docroot/sites/default/services.yml
  chmod go-w /app/docroot/sites/default/services.yml
fi
