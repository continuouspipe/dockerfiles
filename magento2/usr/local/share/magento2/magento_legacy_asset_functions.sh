#!/bin/bash

function do_magento_assets_download() {
  if [ -z "${AWS_S3_BUCKET:-}" ] || [ -z "${ASSET_DOWNLOAD_ENVIRONMENTS:-}" ]; then
    return
  fi

  for asset_env in $ASSET_DOWNLOAD_ENVIRONMENTS; do
    if [ -n "$ASSET_DOWNLOAD_EXCLUDE_PATTERN" ]; then
      as_build "aws s3 sync 's3://${AWS_S3_BUCKET}/${asset_env}' 'tools/assets/${asset_env}' --exclude='${ASSET_DOWNLOAD_EXCLUDE_PATTERN}'"
    else
      as_build "aws s3 sync 's3://${AWS_S3_BUCKET}/${asset_env}' 'tools/assets/${asset_env}'"
    fi
  done
}

function do_magento_assets_install() {
  if [ -z "${ASSET_ARCHIVE_PATH:-}" ] || [ ! -f "${ASSET_ARCHIVE_PATH:-}" ]; then
    return
  fi

  if [ "$IS_CHOWN_FORBIDDEN" != 'true' ]; then
    chown -R "${CODE_OWNER}:${CODE_GROUP}" pub/media
  else
    chmod -R a+rw pub/media
  fi

  echo 'extracting media files'
  as_code_owner "tar --no-same-owner --extract --strip-components=2 --touch --overwrite --gzip --file=$ASSET_ARCHIVE_PATH || exit 1" pub/media

  if [ "$IS_CHOWN_FORBIDDEN" != 'true' ]; then
    chown -R "${APP_USER}:${CODE_GROUP}" pub/media
    chmod -R ug+rw,o-rw pub/media
  else
    chmod -R a+rw pub/media
  fi
}

function do_magento_assets_cleanup() {
  if [ -z "${DATABASE_ARCHIVE_PATH:-}" ] && [ -z "${ASSET_ARCHIVE_PATH:-}" ]; then
    return
  fi

  if [ -d /app/tools/assets/ ]; then
    find /app/tools/assets/ -type f ! -path "*${DATABASE_ARCHIVE_PATH}" -delete
  fi
}

function do_magento_database_install() (
  if [ -z "${DATABASE_ARCHIVE_PATH:-}" ] || [ ! -f "$DATABASE_ARCHIVE_PATH" ]; then
    return
  fi

  set +x
  if [ "${DATABASE_HOST}" != "localhost" ]; then
    wait_for_remote_ports "30" "${DATABASE_HOST}:${DATABASE_PORT}"
  fi
  do_magento_drop_database

  local DATABASE_EXISTS
  DATABASE_EXISTS="$(check_magento_database_exists)"

  if [ "$DATABASE_EXISTS" != "true" ]; then
    do_magento_database_create

    echo 'zcating the magento database dump into the database'
    if [ -n "$DATABASE_ROOT_PASSWORD" ]; then
      zcat "$DATABASE_ARCHIVE_PATH" | mysql -h"$DATABASE_HOST" -uroot -p"$DATABASE_ROOT_PASSWORD" "$DATABASE_NAME" || exit 1
    else
      zcat "$DATABASE_ARCHIVE_PATH" | mysql -h"$DATABASE_HOST" -uroot "$DATABASE_NAME" || exit 1
    fi
  fi
)
