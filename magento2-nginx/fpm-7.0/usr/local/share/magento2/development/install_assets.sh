#!/bin/bash

set -xe

source /usr/local/share/bootstrap/common_functions.sh
source /usr/local/share/bootstrap/setup.sh

cd /app || exit 1

if [ -f "$ASSET_ARCHIVE_PATH" ]; then
  set +e
  is_nfs
  IS_NFS=$?
  set -e

  if [ "$IS_NFS" -ne 0 ]; then
    chown -R "${CODE_OWNER}:${CODE_GROUP}" pub/media
  else
    chmod -R a+rw pub/media
  fi

  echo 'extracting media files'
  as_code_owner "tar --no-same-owner --extract --strip-components=2 --touch --overwrite --gzip --file=$ASSET_ARCHIVE_PATH || exit 1" pub/media

  if [ "$IS_NFS" -ne 0 ]; then
    chown -R "${APP_USER}:${APP_GROUP}" pub/media
    chmod -R u+rw,o-rw pub/media
  else
    chmod -R a+rw pub/media
  fi
fi
