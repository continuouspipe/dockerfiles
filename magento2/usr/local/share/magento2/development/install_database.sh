#!/bin/bash

do_magento_database_restore() (
  set +x
  if [ -f "$DATABASE_ARCHIVE_PATH" ]; then
    local DATABASE_ARGS=(-h"$DATABASE_HOST")

    if [ -n "$DATABASE_ADMIN_USER" ]; then
      DATABASE_ARGS+=(-u"$DATABASE_ADMIN_USER" -p"$DATABASE_ADMIN_PASSWORD")
    else
      DATABASE_ARGS+=(-u"$DATABASE_USER" -p"$DATABASE_PASSWORD")
    fi

    if [ "$FORCE_DATABASE_DROP" == 'true' ]; then
      echo 'Dropping the Magento DB if exists'
      mysql "${DATABASE_ARGS[@]}" -e "DROP DATABASE IF EXISTS $DATABASE_NAME" || exit 1
    fi

    set +e
    mysql "${DATABASE_ARGS[@]}" "$DATABASE_NAME" -e "SHOW TABLES; SELECT FOUND_ROWS() > 0;" | grep -q 1
    DATABASE_EXISTS=$?
    set -e

    if [ "$DATABASE_EXISTS" -ne 0 ]; then
      echo 'Create Magento database'
      echo "CREATE DATABASE IF NOT EXISTS $DATABASE_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" | mysql "${DATABASE_ARGS[@]}"

      if [ -n "${DATABASE_ROOT_PASSWORD:-}" ]; then
        echo "deprecated: granting $DATABASE_USER mysql user access should be moved to mysql service's environment variables and DATABASE_ROOT_PASSWORD removed from this service"
        echo "GRANT ALL ON $DATABASE_NAME.* TO $DATABASE_USER@'%' IDENTIFIED BY '$DATABASE_PASSWORD' ; FLUSH PRIVILEGES" | mysql "${DATABASE_ARGS[@]}"
      fi

      echo 'zcating the magento database dump into the database'
      zcat "$DATABASE_ARCHIVE_PATH" | mysql "${DATABASE_ARGS[@]}" "$DATABASE_NAME" || exit 1
    fi
  fi
)

do_magento_database_restore
