#!/bin/bash

spryker_vhost() {
  local -r TYPE=$1
  # Run confd using the /etc/confd_$TYPE config directory
  # with all WEB_* variables using values set under ${TYPE}_WEB_*
  # or falling back to WEB_* if a ${TYPE}_WEB_* equivalent isn't set

  # shellcheck disable=SC2016
  VARS="$(env | grep -oP "^${TYPE^^}"'_\KWEB_[^=]*' | xargs -I {} echo '{}="$'"${TYPE^^}"'_{}"')"
  bash -c "$(printf "%s " "${VARS[@]}") confd -onetime -confdir=\"/etc/confd_${TYPE,,}\" -backend env"
}

do_spryker_vhosts() {
  rm -f "/etc/apache2/sites-enabled/000-default.conf" "/etc/nginx/sites-enabled/default"
  for VHOST in yves zed; do
    if [ -z "${APP_SERVICES##*${VHOST}*}" ]; then
      spryker_vhost "$VHOST"
    else
      rm -f "/etc/apache2/sites-enabled/"???-"$VHOST.conf" "/etc/nginx/sites-enabled/$VHOST"
    fi
  done
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
  # use Spryker scripts to install static assets
  TERM=linux
  export TERM
  source /app/deploy/setup/util/print.sh
  source /app/deploy/setup/frontend/params.sh
  source /app/deploy/setup/frontend/functions.sh
  setupYvesFrontend
  setupZedFrontend
}

do_generate_files() {
  as_code_owner "vendor/bin/console setup:deploy:prepare-propel"
  as_code_owner "vendor/bin/console transfer:generate"
  as_code_owner "vendor/bin/console setup:search:index-map"
  as_code_owner "vendor/bin/console application:build-navigation-cache"
}

do_setup() {
  ASSETS_FILES_ENABLED="false" do_assets_all
  do_spryker_install
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
