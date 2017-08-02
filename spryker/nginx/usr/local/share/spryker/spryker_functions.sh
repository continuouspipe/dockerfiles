#!/bin/bash

do_spryker_directory_create() {
  as_code_owner "mkdir -p /app/data/DE/cache/Yves/twig"
  as_code_owner "mkdir -p /app/data/DE/cache/Zed/twig"
  as_code_owner "mkdir -p /app/data/DE/logs/ZED"
  as_code_owner "mkdir -p /app/data/common"
}

do_spryker_app_permissions() {
  if [ "$IS_CHOWN_FORBIDDEN" != 'true' ]; then
    # Give the data directory access to the web user.
    chown -R "${CODE_OWNER}":"${APP_GROUP}" /app/data
    chmod -R ug+rw,o-w /app/data
  fi
}

do_spryker_config_create() {
  set +x
  echo "Creating Postgres Credentials file in /root/.pgpass"
  # create .pgpass in home directory for postgres client
  echo "$DATABASE_HOST:*:*:$DATABASE_USER:$DATABASE_PASSWORD" > /root/.pgpass
  chmod 0600 /root/.pgpass
  set -x
}

do_spryker_build() {
  do_spryker_directory_create
  do_spryker_config_create
}

do_build_assets() {
  set +e
  as_code_owner "
    # use Spryker scripts to install static assets
    TERM=linux
    export TERM
    source /app/deploy/setup/util/print.sh
    source /app/deploy/setup/frontend/params.sh
    source /app/deploy/setup/frontend/functions.sh
    setupYvesFrontend
    setupZedFrontend"
  set -e
}

do_generate_files() {
  as_code_owner "vendor/bin/console setup:deploy:prepare-propel"
  as_code_owner "vendor/bin/console transfer:generate"
  as_code_owner "vendor/bin/console setup:search:index-map"
  as_code_owner "vendor/bin/console application:build-navigation-cache"
}

do_spryker_install() {
  # check if database exists (it is supposed to be created by postgres container)
  set +e
    psql -U "$DATABASE_USER" -h "$DATABASE_HOST" -lqt | cut -d \| -f 1 | grep -q "$DATABASE_NAME"
    DATABASE_EXISTS=$?
  set -e

  if [ "$DATABASE_EXISTS" -ne 0 ]; then
    echo "Database does not exist"
    exit 1
  fi

  # database exists
  # check if spryker is installed
  set +e
    psql -U "$DATABASE_USER" -h "$DATABASE_HOST" -c "SELECT EXISTS (SELECT * FROM   information_schema.tables WHERE table_catalog = '$DATABASE_NAME' AND table_name = 'spy_locale');" | grep -q f
    SPRYKER_INSTALLED=$?
  set -e

  if [ "$SPRYKER_INSTALLED" -ne 1 ]; then
    as_code_owner "vendor/bin/console setup:install"
    do_import_demodata
    do_propel_install
    do_product_label_relations_update
    do_run_collectors
    do_setup_search
  fi
}

do_spryker_migrate() {
  do_propel_install

  if [ "$APPLICATION_ENV" != "production" ]; then
    do_run_collectors
  fi
}

do_run_collectors() {
  as_code_owner "vendor/bin/console collector:search:export"
  as_code_owner "vendor/bin/console collector:storage:export"
}

do_propel_install() {
  as_code_owner "vendor/bin/console propel:install"
}

do_import_demodata() {
  if [ -n "$IMPORT_DEMO_DATA_COMMAND" ]; then
    as_code_owner "vendor/bin/console $IMPORT_DEMO_DATA_COMMAND"
  else
    as_code_owner "vendor/bin/console import:demo-data"
  fi
}

do_product_label_relations_update() {
  as_code_owner "vendor/bin/console product-label:relations:update"
}

do_setup_search() {
  as_code_owner "vendor/bin/console setup:search"
}

do_run_tests() {
  as_code_owner "vendor/bin/codecept run --skip Acceptance"
}

do_spryker_hosts() {
    set +e
    grep -q zed /etc/hosts
    HOSTS_UPDATED=$?
    set -e
    if [ "$HOSTS_UPDATED" != "0" ]; then
        # zed is required for internal endpoint and others are required for Acceptance tests to not loop over internet in order to resolve those endpoints
        echo "127.0.0.1 zed $ZED_HOST $YVES_HOST" >> /etc/hosts
    fi
}
