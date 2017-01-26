#!/bin/bash

do_symfony_config_create() {
  # Prepare a default parameters.yml. incenteev/parameters-handler can still update it
  if [ ! -f /app/app/config/parameters.yml ]; then
    echo 'parameters: {}' > /app/app/config/parameters.yml
    if [ "$IS_CHOWN_FORBIDDEN" -ne 0 ]; then
      chown "$CODE_OWNER:$APP_USER" /app/app/config/parameters.yml
      chmod u+rw,g+r,o-rwx /app/app/config/parameters.yml
    else
      chmod a+rw /app/app/config/parameters.yml
    fi
  fi
}

do_symfony_directory_create() {
  if [ "$SYMFONY_MAJOR_VERSION" -eq 2 ]; then
    mkdir -p /app/app/{cache,logs}
  fi
  mkdir -p /app/app/config
  mkdir -p /app/var
}

do_symfony_composer_permissions() {
  # Allow composer to write to certain directories
  if [ "$IS_CHOWN_FORBIDDEN" -ne 0 ]; then
    chown -R "$APP_USER:$CODE_GROUP" /app/var
    chmod -R ug+rw,o-rwx /app/var
  else
    chmod -R a+rw /app/var
  fi
}

do_symfony_build_permissions() {
  if [ "$IS_CHOWN_FORBIDDEN" -ne 0 ]; then
    # Fix permissions so the web server user can write to cache and logs folders
    if [ "$SYMFONY_MAJOR_VERSION" -eq 2 ]; then
      chown -R "$APP_USER:$CODE_GROUP" /app/app/{cache,logs}
      chmod -R ug+rw,o-rwx /app/app/{cache,logs}
    fi
  elif [ "$SYMFONY_MAJOR_VERSION" -eq 2 ]; then
    chmod -R a+rw /app/app/{cache,logs}
  fi
  do_symfony_composer_permissions
}

do_database_rebuild() {
  as_app_user "'$SYMFONY_CONSOLE' doctrine:database:drop --force >/dev/null || true"
  do_database_build
}

do_database_build() {
  # load the database if it doesn't exist
  set +e
  as_app_user "'$SYMFONY_CONSOLE' doctrine:database:create >/dev/null"
  local DATABASE_EXISTED=$?
  set -e

  local QUERY_LINE_COUNT=0
  if [ "$DATABASE_EXISTED" -eq 1 ]; then
    QUERY_LINE_COUNT="$(as_app_user "'$SYMFONY_CONSOLE' doctrine:query:sql 'SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = database()' | wc -l")"
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
  as_app_user "'$SYMFONY_CONSOLE' doctrine:schema:create"
}

do_database_schema_update() {
  as_app_user "'$SYMFONY_CONSOLE' doctrine:schema:update --force"
}

do_database_migrations_mark_done() {
  as_app_user "'$SYMFONY_CONSOLE' doctrine:migrations:version --add --all --no-interaction"
}

do_database_migrate() {
  as_app_user "'$SYMFONY_CONSOLE' doctrine:migrations:migrate --no-interaction"
}

do_cache_clear() {
  as_app_user "'$SYMFONY_CONSOLE' cache:clear"
}

do_database_fixtures() {
  if [ "$SYMFONY_DATABASE_FIXTURE_INSTALL" -eq 1 ]; then
    as_app_user "'$SYMFONY_CONSOLE' doctrine:fixtures:load -n"
  fi
}

do_symfony_build() {
  do_symfony_directory_create
  do_symfony_config_create
  do_symfony_composer_permissions
}
