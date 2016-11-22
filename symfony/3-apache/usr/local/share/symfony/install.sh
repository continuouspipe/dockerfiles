#!/bin/bash

set -xe

source /usr/local/share/bootstrap/common_functions.sh

mkdir -p /app/var

set +e
is_nfs
IS_NFS=$?
set -e

if [ "$IS_NFS" -ne 0 ]; then
  # Ensure code is owned by a user other than the web server user
  chown -R build:build /app
  chmod -R go-rw /app/var
  # Fix permissions so the web server user can write to /app/var for symfony cache files
  setfacl -R -m u:www-data:rwX -m u:build:rwX /app/var
  setfacl -dR -m u:www-data:rwX -m u:build:rwX /app/var
else
  chmod -R a+rw /app/var
fi

if [ ! -d "/app/vendor" ] || [ ! -f "/app/vendor/autoload.php" ]; then
  as_build "composer install --no-interaction --optimize-autoloader"
fi

chmod -R go-w /app/vendor
