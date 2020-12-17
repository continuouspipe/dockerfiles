#!/bin/bash

function do_ez_setup() {
  do_ez_web_server_web_directory_writable
  do_ez_install
  do_ez_migrate
  do_ez_web_server_web_directory_non_writable
}

function do_ez_web_server_web_directory_writable() {
  mkdir -p /app/web/
  if [ "${IS_CHOWN_FORBIDDEN}" != 'true' ]; then
    chown -R "${CODE_OWNER}:${APP_GROUP}" /app/web/
    chmod -R ug+rw,o-w /app/web/
  else
    chmod -R a+rw /app/web/
  fi
}

function do_ez_web_server_web_directory_non_writable() {
  mkdir -p /app/web/
  if [ "${IS_CHOWN_FORBIDDEN}" != 'true' ]; then
    chown -R "${CODE_OWNER}:${APP_GROUP}" /app/web/
    chmod -R u+rw,og-w /app/web/
  else
    chmod -R a+rw /app/web/
  fi
}

function check_ez_database_exists() (
   set +e
   local DATABASE_EXISTS
   if [ -n "$DATABASE_PASSWORD" ]; then
     mysql -h"$DATABASE_HOST" -u"$DATABASE_USER" -p"$DATABASE_PASSWORD" "$DATABASE_NAME" -e "SHOW TABLES; SELECT FOUND_ROWS() > 0;" | grep -q 1
     DATABASE_EXISTS=$?
   else
     mysql -h"$DATABASE_HOST" -u"$DATABASE_USER" "$DATABASE_NAME" -e "SHOW TABLES; SELECT FOUND_ROWS() > 0;" | grep -q 1
     DATABASE_EXISTS=$?
   fi
   if [ "$DATABASE_EXISTS" -eq 0 ]; then
     echo "true";
   else
     echo "false";
   fi
)

function do_ez_install() {
  local DATABASE_EXISTS
  DATABASE_EXISTS="$(check_ez_database_exists)"

  if [ "$DATABASE_EXISTS" != "true" ]; then
    do_symfony_console ezplatform:install "${EZPLATFORM_INSTALL_PROFILE}"
  fi
}

function do_ez_migrate() {
  do_symfony_console kaliop:migration:migrate
}

alias_function do_ez_app_permissions do_symfony_app_permissions
function do_ez_app_permissions() {
  mkdir -p /app/web/var/site/storage
  if [ "${IS_CHOWN_FORBIDDEN}" != 'true' ]; then
    chown -R "$APP_USER:$CODE_GROUP" /app/web/var/site/storage
    chmod -R ug+rw,o-w /app/web/var/site/storage
  else
    chmod -R a+rw /app/web/var/site/storage
  fi
  do_symfony_app_permissions
}
