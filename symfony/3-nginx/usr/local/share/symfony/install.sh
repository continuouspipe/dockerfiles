#!/bin/bash

set -xe

source /usr/local/share/bootstrap/common_functions.sh
source /usr/local/share/php/common_functions.sh

mkdir -p /app/var

cd /app || exit 1;

set +e
is_nfs
IS_NFS=$?
set -e

if [ "$IS_NFS" -ne 0 ]; then
  # Fix permissions so the web server user can write to /app/var for symfony cache files
  chown -R "$CODE_OWNER:$CODE_GROUP" /app
  chown -R "$CODE_OWNER:$APP_GROUP" /app/var
  chmod -R ug+rw,o-rw /app/var
else
  chmod -R a+rw /app/var
fi

run_composer
