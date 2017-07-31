#!/bin/bash

do_spryker_templating() {
  sed 's/"WEB_ADDITIONAL_INCLUDES_NAME/"ZED_WEB_ADDITIONAL_INCLUDES_NAME/' /etc/confd/templates/nginx/site.conf.tmpl > /etc/confd/templates/nginx/site_zed.conf.tmpl
  sed -i'' 's/"WEB_SERVER_NAME/"ZED_WEB_SERVER_NAME/' /etc/confd/templates/nginx/site_zed.conf.tmpl
  sed -i'' 's/ default_server//' /etc/confd/templates/nginx/site_zed.conf.tmpl
}

do_spryker_vhosts() {
  if [ -L /etc/nginx/sites-enabled/default ]; then
    rm /etc/nginx/sites-enabled/default
  fi
  if [ ! -L /etc/nginx/sites-enabled/yves ]; then
    ln -s /etc/nginx/sites-available/yves /etc/nginx/sites-enabled/yves
  fi
  if [ ! -L /etc/nginx/sites-enabled/zed ]; then
    ln -s /etc/nginx/sites-available/zed /etc/nginx/sites-enabled/zed
  fi
}

do_spryker_directory_create() {
  as_code_owner "mkdir -p /app/data/DE/cache/Yves/twig"
  as_code_owner "mkdir -p /app/data/DE/cache/Zed/twig"
  as_code_owner "mkdir -p /app/data/DE/logs"
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
  # create .pgpass in home directory for postgres client
  echo "$DATABASE_HOST:*:*:$DATABASE_USER:$DATABASE_PASSWORD" > /root/.pgpass
  chmod 0600 /root/.pgpass
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

  if [ "$DATABASE_EXISTS" -eq 0 ]; then
    # database exists
    # check if spryker is installed
    set +e
      psql -U spryker_user -h postgres spryker -c "SELECT EXISTS (SELECT * FROM   information_schema.tables WHERE table_catalog = '$DATABASE_NAME' AND table_name = 'spy_locale');" | grep -q f
      SPRYKER_INSTALLED=$?
    set -e

    if [ "$SPRYKER_INSTALLED" -ne 1 ]; then
      as_code_owner "vendor/bin/console setup:install"
      do_import_demodata
      do_run_collectors
      do_setup_search
    fi
  else
    echo "Database does not exist"
  fi
}

do_run_collectors() {
  as_code_owner "vendor/bin/console collector:search:export"
  as_code_owner "vendor/bin/console collector:storage:export"
}

do_import_demodata() {
  as_code_owner "vendor/bin/console import:demo-data"
}

do_setup_search() {
  as_code_owner "vendor/bin/console setup:search"
}

do_run_tests() {
  as_code_owner "vendor/bin/codecept run --skip Acceptance"
}
