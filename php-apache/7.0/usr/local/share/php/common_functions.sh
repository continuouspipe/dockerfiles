#!/bin/bash

source /usr/local/share/bootstrap/common_functions.sh

run_composer() {
  set +e
  is_nfs
  IS_NFS=$?
  set -e

  if [ ! -d "/app/vendor" ] || [ ! -f "/app/vendor/autoload.php" ]; then
    mkdir -p /app/vendor
    if [ "$IS_NFS" -ne 0 ]; then
      chown build:build /app/vendor
    fi

    if [ -n "$GITHUB_TOKEN" ]; then
      as_build "composer config github-oauth.github.com '$GITHUB_TOKEN'"
    fi

    as_build "composer install --no-interaction --optimize-autoloader"
    as_build "composer clear-cache"

    if [ "$IS_NFS" -ne 0 ]; then
      chown -R "$CODE_OWNER:$APP_GROUP" /app/vendor
    fi

    chmod -R go-w /app/vendor
  fi
}
