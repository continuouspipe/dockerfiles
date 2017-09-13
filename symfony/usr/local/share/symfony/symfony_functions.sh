#!/bin/bash

do_symfony_config_create() {
  # Prepare a default parameters.yml. incenteev/parameters-handler can still update it
  if is_false "${SYMFONY_FLEX}" && [ ! -f /app/app/config/parameters.yml ]; then
    mkdir -p /app/app/config
    echo 'parameters: {}' > /app/app/config/parameters.yml
  fi
}

do_symfony_directory_create() {
  if [ "$SYMFONY_MAJOR_VERSION" -eq 2 ]; then
    mkdir -p /app/app/{cache,logs}
  fi
  mkdir -p /app/var
}

do_symfony_app_permissions() {
  if [ "$IS_CHOWN_FORBIDDEN" != 'true' ]; then
    # Fix permissions so the web server user can write to cache and logs folders
    if [ "$SYMFONY_MAJOR_VERSION" -eq 2 ]; then
      chown -R "$APP_USER:$CODE_GROUP" /app/app/{cache,logs}
      chmod -R ug+rw,o-rwx /app/app/{cache,logs}
    fi
    chown -R "$APP_USER:$CODE_GROUP" /app/var
    chmod -R ug+rw,o-rwx /app/var
  else
    if [ "$SYMFONY_MAJOR_VERSION" -eq 2 ]; then
      chmod -R a+rw /app/app/{cache,logs}
    fi
    chmod -R a+rw /app/var
  fi
}


symfony_doctrine_mode() {
  case "$SYMFONY_DOCTRINE_MODE" in
  auto)
    if has_composer_package doctrine/doctrine-migrations-bundle; then
      SYMFONY_DOCTRINE_MODE=migrations
    elif has_composer_package doctrine/doctrine-bundle && has_composer_package doctrine/orm; then
      SYMFONY_DOCTRINE_MODE=schema
    else
      SYMFONY_DOCTRINE_MODE=off
    fi
    ;;
  ?*)
    ;;
  *)
    SYMFONY_DOCTRINE_MODE=off
    ;;
  esac
  export SYMFONY_DOCTRINE_MODE
  echo "$SYMFONY_DOCTRINE_MODE"
}

uses_symfony_doctrine() {
  [ "$(symfony_doctrine_mode)" != "off" ]
  return "$?"
}

uses_symfony_doctrine_mode_schema() {
  [ "$(symfony_doctrine_mode)" = "schema" ]
  return "$?"
}

uses_symfony_doctrine_mode_migrations() {
  [ "$(symfony_doctrine_mode)" = "migrations" ]
  return "$?"
}

do_database_rebuild() {
  if uses_symfony_doctrine; then
    do_symfony_console doctrine:database:drop --force >/dev/null || true
  fi
  do_database_build
}

do_database_build() {
  if ! uses_symfony_doctrine; then
    return 0
  fi

  wait_for_remote_ports "${SYMFONY_DOCTRINE_WAIT_TIMEOUT}" "${DATABASE_HOST}:${DATABASE_PORT}"

  # create the database if it doesn't exist
  do_symfony_console doctrine:database:create --if-not-exists

  local QUERY_LINE_COUNT
  QUERY_LINE_COUNT="$(do_symfony_console doctrine:query:sql 'SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = database()' | wc -l)"

  if [ "$QUERY_LINE_COUNT" -lt 3 ]; then
    do_database_install
  else
    do_database_update
  fi
}

do_database_install() {
  if uses_symfony_doctrine_mode_migrations; then
    do_database_migrate
  elif uses_symfony_doctrine_mode_schema; then
    do_database_schema_create
  fi
  do_database_fixtures
}

do_database_update() {
  if uses_symfony_doctrine_mode_migrations; then
    do_database_migrate
  elif uses_symfony_doctrine_mode_schema; then
    do_database_schema_update
  fi
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
  if has_composer_package doctrine/doctrine-fixtures-bundle; then
    do_symfony_console doctrine:fixtures:load -n
  fi
}

do_symfony_build() {
  do_symfony_directory_create
  do_symfony_config_create
}

do_symfony_console() (
  set +x
  as_app_user "$(escape_shell_args "$SYMFONY_CONSOLE" "$@")"
)
