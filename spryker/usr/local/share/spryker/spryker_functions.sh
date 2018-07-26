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

do_spryker_config_create() (
  set +x
  local target=~/.pgpass

  echo "Creating Postgres Credentials file in "$target
  # create .pgpass in home directory for postgres client
  echo "$DATABASE_HOST:*:*:$DATABASE_USER:$DATABASE_PASSWORD" > $target
  chmod 0600 $target
)

do_spryker_build() {
  do_spryker_directory_create
  do_spryker_config_create

  if [ "$IS_APP_MOUNTPOINT" == 'true' ] || [ "${TASK}" == "build" ]; then
    run_spryker_build
  fi
}

run_spryker_build() {
  if [ "$IMAGE_VERSION" -ge 2 ]; then
    as_code_owner "vendor/bin/install -r docker-build"
  else
    if spryker_service_zed; then
      do_spryker_generate_files
    fi
    do_spryker_build_assets
  fi
  do_spryker_app_permissions
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
  ! spryker_service_yves || spryker_build_assets 'Yves'
  ! spryker_service_zed || spryker_build_assets 'Zed'
}

do_spryker_generate_files() {
  as_code_owner "vendor/bin/console setup:deploy:prepare-propel"
  as_code_owner "vendor/bin/console transfer:generate"
  as_code_owner "vendor/bin/console setup:search:index-map"
  as_code_owner "vendor/bin/console application:build-navigation-cache"
}

create_spryker_database()
(
  if ! postgres_database_exists "${DATABASE_NAME}"; then
    create_postgres_database "${DATABASE_NAME}"
  else
    echo "'${DATABASE_NAME}' Postgres database already exists, not creating"
  fi
)

is_spryker_installed()
{
  postgres_has_table 'spy_locale'
}

do_spryker_install() {
  create_spryker_database
  if ! is_spryker_installed; then
    run_spryker_installer
  fi
}

run_spryker_installer()
{
  if [ "$IMAGE_VERSION" -ge 2 ]; then
    as_code_owner "vendor/bin/install -r docker-install"
  else
    as_code_owner "vendor/bin/console setup:install"
    do_spryker_import_demodata
    do_spryker_product_label_relations_update
    do_spryker_setup_search
    do_spryker_directory_create
    do_spryker_app_permissions
    do_spryker_run_collectors
  fi
}

do_spryker_migrate()
{
  if [ "$IMAGE_VERSION" -ge 2 ]; then
    as_code_owner "vendor/bin/install -r docker-migrate"
  else
    do_spryker_propel_install
  fi
}

do_spryker_run_collectors() {
  as_app_user "vendor/bin/console collector:storage:export"
  as_app_user "vendor/bin/console collector:search:export"
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

do_spryker_console() (
  set +x
  as_app_user "$(escape_shell_args vendor/bin/console "$@")"
)
