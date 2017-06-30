#!/bin/bash

do_symfony_config_create() {
  # Prepare a default parameters.yml. incenteev/parameters-handler can still update it
  if [ ! -f /app/app/config/parameters.yml ]; then
    echo 'parameters: {}' > /app/app/config/parameters.yml
  fi
}

do_symfony_directory_create() {
  if [ "$SYMFONY_MAJOR_VERSION" -eq 2 ]; then
    mkdir -p /app/app/{cache,logs}
  fi
  mkdir -p /app/app/config
  mkdir -p /app/var
}

do_symfony_app_permissions() {
  # Fix permissions so the web server user can write to cache and logs folders
  if [ "$SYMFONY_MAJOR_VERSION" -eq 2 ]; then
    do_ownership "/app/app/cache /app/app/logs" "$APP_USER" "$CODE_GROUP"
    do_remove_other_permissions "/app/app/cache /app/app/logs"
  fi
  do_ownership "/app/var" "$APP_USER" "$CODE_GROUP"
  do_remove_other_permissions "/app/var"
}

do_database_rebuild() {
  do_symfony_console doctrine:database:drop --force >/dev/null || true
  do_database_build
}

do_database_build() {
  # load the database if it doesn't exist
  set +e
  do_symfony_console doctrine:database:create >/dev/null
  local DATABASE_EXISTED=$?
  set -e

  local QUERY_LINE_COUNT=0
  if [ "$DATABASE_EXISTED" -eq 1 ]; then
    QUERY_LINE_COUNT="$(do_symfony_console doctrine:query:sql 'SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = database()' | wc -l)"
  fi

  if [ "$DATABASE_EXISTED" -ne 1 ] || [ "$QUERY_LINE_COUNT" -lt 3 ]; then
    do_database_install
  else
    do_database_update
  fi
}

do_database_install() {
  do_database_schema_create
  do_database_migrations_mark_done
  do_database_fixtures
}

do_database_update() {
  do_database_migrate
}

do_database_schema_create() {
  do_symfony_console doctrine:schema:create
}

do_database_schema_update() {
  do_symfony_console doctrine:schema:update --force
}

do_database_migrations_mark_done() {
  do_symfony_console doctrine:migrations:version --add --all --no-interaction
}

do_database_migrate() {
  do_symfony_console doctrine:migrations:migrate --no-interaction
}

do_cache_clear() {
  do_symfony_console cache:clear
}

do_database_fixtures() {
  do_symfony_console doctrine:fixtures:load -n
}

do_symfony_build() {
  do_symfony_directory_create
  do_symfony_config_create
}

do_symfony_console() {
  set +x
  if [ "$#" -gt 0 ]; then
    as_app_user "'$SYMFONY_CONSOLE' $(printf "%q " "$@")"
  else
    as_app_user "'$SYMFONY_CONSOLE'"
  fi
}
