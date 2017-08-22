#!/bin/bash

set -e

source /usr/local/share/bootstrap/common_functions.sh
source /usr/local/share/bootstrap/setup.sh

set -x

cd /app || exit 1

if [ -f "$ASSET_ARCHIVE_PATH" ]; then
  IS_CHOWN_FORBIDDEN="$(run_return_boolean is_chown_forbidden)"

  if [ "$IS_CHOWN_FORBIDDEN" != 'true' ]; then
    chown -R "${CODE_OWNER}:${CODE_GROUP}" pub/media
  else
    chmod -R a+rw pub/media
  fi

  echo 'extracting media files'
  as_code_owner "tar --no-same-owner --extract --strip-components=2 --touch --overwrite --gzip --file=$ASSET_ARCHIVE_PATH || exit 1" pub/media

  if [ "$IS_CHOWN_FORBIDDEN" != 'true' ]; then
    chown -R "${APP_USER}:${APP_GROUP}" pub/media
    chmod -R u+rw,o-rw pub/media
  else
    chmod -R a+rw pub/media
  fi
fi
