#!/bin/bash

if [ -f "$DATABASE_ARCHIVE_PATH" ]; then
  if [ "$FORCE_DATABASE_DROP" == 'true' ]; then
    echo 'Dropping the Magento DB if exists'
    mysql -h"$DATABASE_HOST" -uroot -p"$DATABASE_ROOT_PASSWORD" -e "DROP DATABASE IF EXISTS $DATABASE_NAME" || exit 1
  fi

  set +e
  mysql -h"$DATABASE_HOST" -u"$DATABASE_USER" -p"$DATABASE_PASSWORD" "$DATABASE_NAME" -e "SHOW TABLES; SELECT FOUND_ROWS() > 0;" | grep -q 1
  DATABASE_EXISTS=$?
  set -e

  if [ "$DATABASE_EXISTS" -ne 0 ]; then
    echo 'Create Magento database'
    echo "CREATE DATABASE IF NOT EXISTS $DATABASE_NAME ; GRANT ALL ON $DATABASE_NAME.* TO $DATABASE_USER@'%' IDENTIFIED BY '$DATABASE_PASSWORD' ; FLUSH PRIVILEGES" |  mysql -uroot -p"$DATABASE_ROOT_PASSWORD" -h"$DATABASE_HOST"

    echo 'zcating the magento database dump into the database'
    zcat "$DATABASE_ARCHIVE_PATH" | mysql -h"$DATABASE_HOST" -uroot -p"$DATABASE_ROOT_PASSWORD" "$DATABASE_NAME" || exit 1
  fi
fi
