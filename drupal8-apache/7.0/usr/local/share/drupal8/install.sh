#!/bin/bash
set -xe

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi ;

# shellcheck source=./common_functions.sh
source "$DIR/common_functions.sh";

cd /app || exit 1;

if [ ! -d "/app/vendor" ] || [ ! -f "/app/vendor/autoload.php" ]; then
  if [ -n "$GITHUB_TOKEN" ]; then
    as_build "composer config github-oauth.github.com '$GITHUB_TOKEN'"
  fi

  as_build "composer install --optimize-autoloader --no-interaction"
  as_build "composer clear-cache"

  chmod -R go-w vendor
fi

cd /app/docroot || exit 1;

SETTINGS_DIR="/app/docroot/sites/default"

if [ ! -f "$SETTINGS_DIR/settings.php" ]; then
  mkdir -p "$SETTINGS_DIR"
  chmod u+w "$SETTINGS_DIR"
  cp /app/tools/docker/config/settings.php "$SETTINGS_DIR/settings.php"
  chmod go-w "$SETTINGS_DIR/settings.php"
  chmod a-w "$SETTINGS_DIR"
fi

if [ ! -f "$SETTINGS_DIR/services.yml" ]; then
  mkdir -p "$SETTINGS_DIR"
  chmod u+w "$SETTINGS_DIR"

  SOURCE_FILE="$SETTINGS_DIR/default.services.yml"
  if [ -f /app/tools/docker/config/services.yml ]; then
    SOURCE_FILE="/app/tools/docker/config/services.yml"
  fi

  cp "$SOURCE_FILE" "$SETTINGS_DIR/services.yml"
  chmod go-w "$SETTINGS_DIR/services.yml"

  chmod a-w "$SETTINGS_DIR"
fi

CURRENT_TABLES="$(as_build "drush sql-query 'SHOW TABLES;'" /app/docroot)"
if [ "$CURRENT_TABLES" == '' ]; then
  chmod u+w "$SETTINGS_DIR" || true
  mkdir -p "$SETTINGS_DIR/files/"
  as_build "echo 'y' | drush site-install lightning" "/app/docroot"
  chmod a-w "$SETTINGS_DIR"
fi

if [ -f "$DIR/install_custom.sh" ]; then
  bash "$DIR/install_custom.sh"
fi
