#!/bin/bash
set -xe

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi

source /usr/local/share/bootstrap/common_functions.sh
source /usr/local/share/php/common_functions.sh

cd /app || exit 1;

run_composer

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

if [ -f "$DIR/install_custom.sh" ]; then
  bash "$DIR/install_custom.sh"
fi
