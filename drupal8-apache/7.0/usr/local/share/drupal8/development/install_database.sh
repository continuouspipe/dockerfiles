#!/bin/sh

if [ -f tools/assets/development/drupaldb.sql.gz ]; then
  echo 'Dropping the Drupal DB if exists'
  mysql -h"$DATABASE_HOST" -uroot -p"$DATABASE_ROOT_PASSWORD" -e "DROP DATABASE IF EXISTS $DATABASE_NAME" || exit 1

  echo 'Create drupal database'
  echo "create database $DATABASE_NAME ; grant ALL on $DATABASE_NAME.* to $DATABASE_USER@'%' identified by '$DATABASE_PASSWORD' ; flush privileges" |  mysql -uroot -p"$DATABASE_ROOT_PASSWORD" -h"$DATABASE_HOST"

  echo 'zcating the drupal database dump into the database'
  zcat tools/assets/development/drupaldb.sql.gz | mysql -h"$DATABASE_HOST" -uroot -p"$DATABASE_ROOT_PASSWORD" "$DATABASE_NAME" || exit 1
fi
