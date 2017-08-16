#!/bin/bash

spryker_service_yves() {
  [ -z "${APP_SERVICES##*yves*}" ]
  return "$?"
}

spryker_service_zed() {
  [ -z "${APP_SERVICES##*zed*}" ]
  return "$?"
}

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
    if "spryker_service_$VHOST"; then
      spryker_vhost "$VHOST"
    else
      rm -f "/etc/apache2/sites-enabled/"???-"$VHOST.conf" "/etc/nginx/sites-enabled/$VHOST"
    fi
  done
}

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

  if [ "$IS_APP_MOUNTPOINT" == 'true' ] || [ "${TASK}" == "build" ]; then
    if spryker_service_zed; then
      do_spryker_generate_files
    fi
    do_spryker_build_assets
    do_spryker_app_permissions
  fi
}

spryker_build_assets() {
  local -r TYPE="$1"
  as_code_owner "
    # use Spryker scripts to install static assets
    TERM=linux
    export TERM
    source /app/deploy/setup/util/print.sh
    source /app/deploy/setup/frontend/params.sh
    source /app/deploy/setup/frontend/functions.sh
    setup${TYPE}Frontend
  "
}

do_spryker_build_assets() {
  set +e
  ! spryker_service_yves || spryker_build_assets 'Yves'
  ! spryker_service_zed || spryker_build_assets 'Zed'
  set -e
}

do_spryker_generate_files() {
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
    do_spryker_import_demodata
    do_spryker_product_label_relations_update
    do_spryker_setup_search
    do_spryker_run_collectors
  fi
}

do_spryker_migrate() {
  do_spryker_propel_install
}

do_spryker_run_collectors() {
  as_code_owner "vendor/bin/console collector:search:export"
  as_code_owner "vendor/bin/console collector:storage:export"
}

do_spryker_propel_install() {
  as_code_owner "vendor/bin/console propel:install -o"
}

do_spryker_import_demodata() {
  if [ -n "$IMPORT_DEMO_DATA_COMMAND" ]; then
    as_code_owner "vendor/bin/console $IMPORT_DEMO_DATA_COMMAND"
  else
    as_code_owner "vendor/bin/console import:demo-data"
  fi
}

do_spryker_product_label_relations_update() {
  as_code_owner "vendor/bin/console product-label:relations:update"
}

do_spryker_setup_search() {
  as_code_owner "vendor/bin/console setup:search"
}

do_spryker_run_tests() {
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
