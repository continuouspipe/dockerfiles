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
      chown "$CODE_OWNER":"$CODE_GROUP" /app/vendor
    fi

    if [ -n "$GITHUB_TOKEN" ]; then
      as_code_owner "composer global config github-oauth.github.com '$GITHUB_TOKEN'"
    fi

    as_code_owner "composer install --no-interaction --optimize-autoloader"
    rm -rf /home/build/.composer/cache/
    as_code_owner "composer clear-cache"

    if [ "$IS_NFS" -ne 0 ]; then
      chown -R "$CODE_OWNER:$APP_GROUP" /app/vendor
    fi

    chmod -R go-w /app/vendor
  fi
}
