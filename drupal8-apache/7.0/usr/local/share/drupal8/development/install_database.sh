#!/bin/bash

function database_connected() {
  mysql -h"$DATABASE_HOST" -u"$DATABASE_USER" -p"$DATABASE_PASSWORD" -e "SELECT 1;"
}

function database_exists() {
  mysql -h"$DATABASE_HOST" -u"$DATABASE_USER" -p"$DATABASE_PASSWORD" "$DATABASE_NAME" -e "SHOW TABLES; SELECT FOUND_ROWS() > 0;" | grep -q 1
}

if [ -f tools/assets/development/drupaldb.sql.gz ]; then
  if [ "$FORCE_DATABASE_DROP" == 'true' ]; then
    echo 'Dropping the Drupal DB if exists'
    mysql -h"$DATABASE_HOST" -uroot -p"$DATABASE_ROOT_PASSWORD" -e "DROP DATABASE IF EXISTS $DATABASE_NAME" || exit 1
  fi

  set +e
  database_connected
  DATABASE_CONNECTED=$?

  database_exists
  DATABASE_EXISTS=$?
  set -e

  if [ "$DATABASE_CONNECTED" -eq 0 ] && [ "$DATABASE_EXISTS" -ne 0 ]; then
    echo 'Create drupal database'
    echo "CREATE DATABASE IF NOT EXISTS $DATABASE_NAME ; GRANT ALL ON $DATABASE_NAME.* TO $DATABASE_USER@'%' IDENTIFIED BY '$DATABASE_PASSWORD' ; FLUSH PRIVILEGES" |  mysql -uroot -p"$DATABASE_ROOT_PASSWORD" -h"$DATABASE_HOST"

    echo 'zcating the drupal database dump into the database'
    zcat tools/assets/development/drupaldb.sql.gz | mysql -h"$DATABASE_HOST" -uroot -p"$DATABASE_ROOT_PASSWORD" "$DATABASE_NAME" || exit 1
  fi
else
  set +e
  database_connected
  DATABASE_CONNECTED=$?

  database_exists
  DATABASE_EXISTS=$?
  set -e

  if [ "$DATABASE_CONNECTED" -eq 0 ] && [ "$DATABASE_EXISTS" -ne 0 ]; then
    SETTINGS_DIR="/app/docroot/sites/default"

    chmod u+w "$SETTINGS_DIR" || true
    mkdir -p "$SETTINGS_DIR/files/"

    # Install a database if there isn't one yet
    set +e
    as_code_owner "drush sql-query 'SHOW TABLES;' | grep -v cache | grep -q ''" /app/docroot
    HAS_CURRENT_TABLES=$?
    set -e
    if [ "$HAS_CURRENT_TABLES" -ne 0 ] && [ -n "$DRUPAL_INSTALL_PROFILE" ]; then
      chown "$CODE_OWNER:$CODE_GROUP" "$SETTINGS_DIR/files/"
      as_code_owner "echo 'y' | drush site-install $DRUPAL_INSTALL_PROFILE" "/app/docroot"
      chown -R "$APP_USER:$APP_GROUP" "$SETTINGS_DIR/files/"
    fi

    chmod a-w "$SETTINGS_DIR"
  fi
fi
