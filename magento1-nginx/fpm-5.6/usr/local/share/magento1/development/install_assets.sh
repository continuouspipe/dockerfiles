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
    chown -R "${CODE_OWNER}:${CODE_GROUP}" public/media
  else
    chmod -R a+rw public/media
  fi

  echo 'extracting media files'
  as_code_owner "tar --no-same-owner --extract --strip-components=2 --touch --overwrite --gzip --file=$ASSET_ARCHIVE_PATH || exit 1" public/media

  if [ "$IS_NFS" -ne 0 ]; then
    chown -R "${APP_USER}:${APP_GROUP}" public/media
    chmod -R u+rw,go-w,go+r public/media
  else
    chmod -R a+rw public/media
  fi
fi
