#!/bin/bash

set -xe

source /usr/local/share/bootstrap/common_functions.sh

mkdir -p /app/var

set +e
is_nfs
IS_NFS=$?
set -e

if [ "$IS_NFS" -ne 0 ]; then
  chown -R build:build /app
  setfacl -R -m u:www-data:rwX -m u:build:rwX var
  setfacl -dR -m u:www-data:rwX -m u:build:rwX var
fi

if [ ! -d "/app/vendor" ] || [ ! -f "/app/vendor/autoload.php" ]; then
  as_build "composer install --no-interaction --optimize-autoloader"
fi

chmod -R go-w /app/vendor
