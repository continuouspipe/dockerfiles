#!/bin/bash

set -xe

source /usr/local/share/bootstrap/common_functions.sh

if [ -f /app/tools/assets/development/media.files.tgz ]; then
  set +e
  is_nfs
  IS_NFS=$?
  set -e

  if [ "$IS_NFS" -eq 0 ]; then
    chown -R "${CODE_OWNER}:${CODE_GROUP}" /app/pub/media
  else
    chmod -R a+rw /app/pub/media
  fi

  echo 'extracting media files'
  as_code_owner "tar --no-same-owner --extract --strip-components=2 --gzip --file=/app/tools/assets/development/media.files.tgz || exit 1" /app/pub/media

  if [ "$IS_NFS" -eq 0 ]; then
    chown -R "${APP_USER}:${APP_GROUP}" /app/pub/media
    chmod -R u+rw,o-rw /app/media
  else
    chmod -R a+rw /app/pub/media
  fi
fi
