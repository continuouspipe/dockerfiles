#!/bin/bash

do_spryker_directory_create() {
  mkdir -p /app/data/DE/cache/Yves/twig
  mkdir -p /app/data/DE/cache/Zed/twig
  mkdir -p /app/data/DE/logs
  mkdir -p /app/data/common
}

do_spryker_app_permissions() {
  if [ "$IS_CHOWN_FORBIDDEN" -ne 0 ]; then
    # Give the data directory access to the web user.
    chown -R "${CODE_OWNER}":"${APP_GROUP}" /app/data
    chmod -R ug+rw,o-w /app/data
  fi
}

do_spryker_config_create() {
  # create .pgpass in home directory for postgres client
  as_code_owner "echo \"$DATABASE_HOST:*:*:$DATABASE_USER:$DATABASE_PASSWORD\" > ~/.pgpass"
  as_code_owner "chmod 0600 ~/.pgpass"
}

do_spryker_build() {
  do_spryker_directory_create
  do_spryker_config_create
}

do_build_assets() {
  as_code_owner "cd /app && npm run zed"
  as_code_owner "cd /app && npm run yves"
}

do_database_update() {
  as_code_owner "/app/vendor/bin/console setup:deploy:prepare-propel"
  as_code_owner "/app/vendor/bin/console transfer:generate"
  as_code_owner "/app/vendor/bin/console setup:search:index-map"
  as_code_owner "/app/vendor/bin/console application:build-navigation-cache"
}

do_setup() {
  do_build_assets
  do_database_update
}

do_spryker_install() {
  as_code_owner "/app/vendor/bin/console setup:install"
  as_code_owner "/app/vendor/bin/console import:demo-data"
  as_code_owner "/app/vendor/bin/console collector:search:export"
  as_code_owner "/app/vendor/bin/console collector:storage:export"
  as_code_owner "/app/vendor/bin/console setup:search"
}
