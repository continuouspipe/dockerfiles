#!/bin/bash

function do_composer_config() {
  as_code_owner "composer global config repositories.magento composer https://repo.magento.com/"

  if [ -n "$MAGENTO_USERNAME" ] && [ -n "$MAGENTO_PASSWORD" ]; then
    as_code_owner "composer global config http-basic.repo.magento.com '$MAGENTO_USERNAME' '$MAGENTO_PASSWORD'"
  fi
  if [ -n "$COMPOSER_CUSTOM_CONFIG_COMMAND" ]; then
    as_code_owner "$COMPOSER_CUSTOM_CONFIG_COMMAND"
  fi
}

function do_composer_pre_install() {
  mkdir -p /app/bin
  chown -R "${CODE_OWNER}:${CODE_GROUP}" /app/bin
}

function do_composer_post_install() {
  if [ -f /app/bin/magento ]; then
    chmod +x /app/bin/magento
  fi
}

function do_magento_create_web_writable_directories() {
  mkdir -p pub/media pub/static var/log var/report var/generation generated

  if [ "$IS_CHOWN_FORBIDDEN" != 'true' ]; then
    chown -R "${APP_USER}:${CODE_GROUP}" pub/media pub/static var generated
    chmod -R ug+rw,o-w pub/media pub/static var generated
  else
    chmod -R a+rw pub/media pub/static var generated
  fi
}

function do_magento_frontend_build() {
  if [ -d "$FRONTEND_INSTALL_DIRECTORY" ]; then
    mkdir -p pub/static/frontend/

  if [ -d "pub/static/frontend/" ] && [ "$IS_CHOWN_FORBIDDEN" != 'true' ]; then
      chown -R "${CODE_OWNER}:${CODE_GROUP}" pub/static/frontend/
    fi

    if [ ! -d "$FRONTEND_INSTALL_DIRECTORY/node_modules" ]; then
      as_code_owner "npm install" "$FRONTEND_INSTALL_DIRECTORY"
    fi
    if [ -z "$GULP_BUILD_THEME_NAME" ]; then
      as_code_owner "gulp $FRONTEND_BUILD_ACTION" "$FRONTEND_BUILD_DIRECTORY"
    else
      as_code_owner "gulp $FRONTEND_BUILD_ACTION --theme='$GULP_BUILD_THEME_NAME'" "$FRONTEND_BUILD_DIRECTORY"
    fi

  if [ -d "pub/static/frontend/" ] && [ "$IS_CHOWN_FORBIDDEN" != 'true' ]; then
      chown -R "${APP_USER}:${APP_GROUP}" pub/static/frontend/
    fi
  fi
}

function do_magento_install_custom() {
  if [ -f "/usr/local/share/magento2/install_magento_custom.sh" ]; then
    # shellcheck source=./install_magento_custom.sh
    source "/usr/local/share/magento2/install_magento_custom.sh"
  fi
}

function do_magento_switch_web_writable_directories_to_code_owner() {
  if [ "$IS_CHOWN_FORBIDDEN" != 'true' ]; then
    chown -R "${CODE_OWNER}":"${CODE_GROUP}" pub/media pub/static var generated
  else
    chmod a+rw pub/media pub/static var generated
  fi
}

function do_magento_move_compiled_assets_away_from_codebase() {
  # Preserve compiled theme files across setup:upgrade calls.
  if [ -d pub/static/frontend/ ]; then
    mkdir /tmp/assets
    mv pub/static/frontend/ /tmp/assets/
  fi
}

function do_magento_setup_upgrade() {
  do_magento_clear_redis_cache
  as_code_owner "bin/magento setup:upgrade"
}

function do_magento_move_compiled_assets_back_to_codebase() {
  if [ -d /tmp/assets/ ]; then
    mkdir -p pub/static/
    mv /tmp/assets/frontend/ pub/static/
    rm -rf /tmp/assets
  fi
}

function do_magento_dependency_injection_compilation() {
  # Compile the DIC if to be productionized
  if [ "$PRODUCTION_ENVIRONMENT" = "true" ]; then
    as_code_owner "$MAGENTO_DEPENDENCY_INJECTION_COMPILE_COMMAND"
  fi
}

function do_magento_deploy_static_content() {
  # Compile static content if it's a production container.
  if [ "$MAGENTO_MODE" = "production" ]; then
    set +e
    run_magento_deploy_static_content "" "--no-javascript $FRONTEND_COMPILE_LANGUAGES"
    run_magento_deploy_static_content "on" "--no-css --no-less --no-images --no-fonts --no-html --no-misc --no-html-minify $FRONTEND_COMPILE_LANGUAGES"
    set -e
  fi
}

function run_magento_deploy_static_content() {
  local FLAGS="$2"
  HTTPS="$1" as_code_owner "bin/magento setup:static-content:deploy $FLAGS"
}

function do_magento_reindex() {
  (as_code_owner "bin/magento indexer:reindex" || echo "Failing indexing to the end, ignoring.") && echo "Indexing successful"
}

function do_magento_assets_download() {
  if [ -n "$AWS_S3_BUCKET" ]; then
    for asset_env in $ASSET_DOWNLOAD_ENVIRONMENTS; do
      if [ -n "$ASSET_DOWNLOAD_EXCLUDE_PATTERN" ]; then
        as_build "aws s3 sync 's3://${AWS_S3_BUCKET}/${asset_env}' 'tools/assets/${asset_env}' --exclude='${ASSET_DOWNLOAD_EXCLUDE_PATTERN}'"
      else
        as_build "aws s3 sync 's3://${AWS_S3_BUCKET}/${asset_env}' 'tools/assets/${asset_env}'"
      fi
    done
  fi
}

function do_magento_clear_redis_cache() {
  if [ "$MAGENTO_USE_REDIS" != "true" ]; then
    return
  fi

  local REDIS_HOST="$REDIS_HOST"
  local REDIS_HOST_PORT="$REDIS_HOST_PORT"

  if [ "$REDIS_USE_SENTINEL" == "true" ]; then
    local MASTER_REDIS_DETAILS
    MASTER_REDIS_DETAILS="$(redis-cli -h "$REDIS_SENTINEL_SERVICE_HOST" -p "$REDIS_SENTINEL_SERVICE_PORT" --csv SENTINEL get-master-addr-by-name "$REDIS_SENTINEL_MASTER" | tr ',' ' ')"
    REDIS_HOST="$(echo "$MASTER_REDIS_DETAILS" | cut -d' ' -f1)"
    REDIS_HOST="${REDIS_HOST//\"}"
    REDIS_HOST_PORT="$(echo "$MASTER_REDIS_DETAILS" | cut -d' ' -f2)"
    REDIS_HOST_PORT="${REDIS_HOST_PORT//\"}"
  fi

  redis-cli -h "$REDIS_HOST" -p "$REDIS_HOST_PORT" -n "$MAGENTO_REDIS_CACHE_DATABASE" "FLUSHDB"
  redis-cli -h "$REDIS_HOST" -p "$REDIS_HOST_PORT" -n "$MAGENTO_REDIS_FULL_PAGE_CACHE_DATABASE" "FLUSHDB"
}

function do_magento_cache_flush() {
  do_magento_clear_redis_cache
  # Flush magento cache
  as_code_owner "bin/magento cache:flush"
}

function do_magento_install_finalise_custom() {
  if [ -f "/usr/local/share/magento2/install_magento_finalise_custom.sh" ]; then
    # shellcheck source=./install_magento_finalise_custom.sh
    source "/usr/local/share/magento2/install_magento_finalise_custom.sh"
  fi
}

function do_magento_drop_database() {
  set +x

  if [ "$FORCE_DATABASE_DROP" != 'true' ]; then
    return
  fi

  echo 'Dropping the Magento DB if exists'
  if [ -n "$DATABASE_ROOT_PASSWORD" ]; then
    mysql -h"$DATABASE_HOST" -uroot -p"$DATABASE_ROOT_PASSWORD" -e "DROP DATABASE IF EXISTS $DATABASE_NAME" || exit 1
  else
    mysql -h"$DATABASE_HOST" -uroot -e "DROP DATABASE IF EXISTS $DATABASE_NAME" || exit 1
  fi
}

function check_magento_database_exists() {
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
}

function do_magento_database_create() {
  echo 'Create Magento database'
  if [ -n "$DATABASE_ROOT_PASSWORD" ]; then
    echo "CREATE DATABASE IF NOT EXISTS $DATABASE_NAME ; GRANT ALL ON $DATABASE_NAME.* TO $DATABASE_USER@'$DATABASE_USER_HOST' IDENTIFIED BY '$DATABASE_PASSWORD' ; FLUSH PRIVILEGES" |  mysql -uroot -p"$DATABASE_ROOT_PASSWORD" -h"$DATABASE_HOST"
  else
    echo "CREATE DATABASE IF NOT EXISTS $DATABASE_NAME ; GRANT ALL ON $DATABASE_NAME.* TO $DATABASE_USER@'$DATABASE_USER_HOST' IDENTIFIED BY '$DATABASE_PASSWORD' ; FLUSH PRIVILEGES" |  mysql -uroot -h"$DATABASE_HOST"
  fi
}

function do_magento_database_install() {
  set +x
  if [ "${DATABASE_HOST}" != "localhost" ]; then
    wait_for_remote_ports "30" "${DATABASE_HOST}:${DATABASE_PORT}"
  fi
  if [ -f "$DATABASE_ARCHIVE_PATH" ]; then
    do_magento_drop_database

    local DATABASE_EXISTS
    DATABASE_EXISTS="$(check_magento_database_exists)"
    set -e

    if [ "$DATABASE_EXISTS" != "true" ]; then
      do_magento_database_create

      echo 'zcating the magento database dump into the database'
      if [ -n "$DATABASE_ROOT_PASSWORD" ]; then
        zcat "$DATABASE_ARCHIVE_PATH" | mysql -h"$DATABASE_HOST" -uroot -p"$DATABASE_ROOT_PASSWORD" "$DATABASE_NAME" || exit 1
      else
        zcat "$DATABASE_ARCHIVE_PATH" | mysql -h"$DATABASE_HOST" -uroot "$DATABASE_NAME" || exit 1
      fi
    fi
  fi
  set -x
}

function do_magento_installer_install() {
  set +x
  if [ "${DATABASE_HOST}" != "localhost" ]; then
    wait_for_remote_ports "30" "${DATABASE_HOST}:${DATABASE_PORT}"
  fi
  do_magento_wait_for_database
  do_magento_drop_database

  local DATABASE_EXISTS
  DATABASE_EXISTS="$(check_magento_database_exists)"
  set -e

  if [ "$DATABASE_EXISTS" != "true" ]; then
    do_magento_database_create
    do_magento_clear_redis_cache
    magento_installer_install
  fi

  set -x
}

function magento_installer_install() {
  echo 'Install Magento 2 via the Installer'
  chmod +x bin/magento
  local INSTALL_COMMAND="bin/magento setup:install --base-url='$PUBLIC_ADDRESS' \
    --db-host='$DATABASE_HOST' \
    --db-name='$DATABASE_NAME' \
    --db-user='$DATABASE_USER' \
    --admin-firstname=Admin \
    --admin-lastname=Demo \
    --admin-user='${MAGENTO_ADMIN_USERNAME:-admin}' \
    --admin-password='${MAGENTO_ADMIN_PASSWORD:-admin123}' \
    --admin-email='${MAGENTO_ADMIN_EMAIL:-admin@example.com}' \
    --language=en_GB \
    --currency=GBP \
    --timezone=Europe/London \
    --use-rewrites=1 \
    --session-save=db"
  if [ -n "$DATABASE_PASSWORD" ]; then
    INSTALL_COMMAND="${INSTALL_COMMAND} --db-password='${DATABASE_PASSWORD}'"
  fi
  as_code_owner "$INSTALL_COMMAND"
}

function do_magento_wait_for_database() {
  if [ "$DATABASE_HOST" != 'localhost' ]; then
    return
  fi

  while [ ! -S /var/run/mysqld/mysqld.sock ]; do
    echo "Waiting for a mysql server"
    sleep 5
  done
}

function do_magento_assets_install() {
  if [ -f "$ASSET_ARCHIVE_PATH" ]; then
    if [ "$IS_CHOWN_FORBIDDEN" != 'true' ]; then
      chown -R "${CODE_OWNER}:${CODE_GROUP}" pub/media
    else
      chmod -R a+rw pub/media
    fi

    echo 'extracting media files'
    as_code_owner "tar --no-same-owner --extract --strip-components=2 --touch --overwrite --gzip --file=$ASSET_ARCHIVE_PATH || exit 1" pub/media

    if [ "$IS_CHOWN_FORBIDDEN" != 'true' ]; then
      chown -R "${APP_USER}:${CODE_GROUP}" pub/media
      chmod -R ug+rw,o-rw pub/media
    else
      chmod -R a+rw pub/media
    fi
  fi
}

function do_magento_assets_cleanup() {
  if [ -d /app/tools/assets/ ]; then
    find /app/tools/assets/ -type f ! -path "*${DATABASE_ARCHIVE_PATH}" -delete
  fi
}

function do_magento_install_development_custom() {
  if [ -f "/usr/local/share/magento2/development/install_custom.sh" ]; then
    # shellcheck source=./install_custom.sh
    source "/usr/local/share/magento2/development/install_custom.sh"
  fi
}

function do_replace_core_config_values() {
  set +x
  local SQL
  SQL="DELETE from core_config_data WHERE path LIKE 'web/%base_url';
  DELETE from core_config_data WHERE path LIKE 'system/full_page_cache/varnish%';
  INSERT INTO core_config_data VALUES (NULL, 'default', '0', 'web/unsecure/base_url', '$PUBLIC_ADDRESS');
  INSERT INTO core_config_data VALUES (NULL, 'default', '0', 'web/secure/base_url', '$PUBLIC_ADDRESS');
  INSERT INTO core_config_data VALUES (NULL, 'default', '0', 'system/full_page_cache/varnish/access_list', 'varnish');
  INSERT INTO core_config_data VALUES (NULL, 'default', '0', 'system/full_page_cache/varnish/backend_host', 'web');
  INSERT INTO core_config_data VALUES (NULL, 'default', '0', 'system/full_page_cache/varnish/backend_port', '80');
  $ADDITIONAL_SETUP_SQL"

  echo "Running the following SQL on $DATABASE_HOST.$DATABASE_NAME:"
  echo "$SQL"

  if [ -n "$DATABASE_PASSWORD" ]; then
    echo "$SQL" | mysql -h"$DATABASE_HOST" -u"$DATABASE_USER" -p"$DATABASE_PASSWORD" "$DATABASE_NAME"
  else
    echo "$SQL" | mysql -h"$DATABASE_HOST" -u"$DATABASE_USER" "$DATABASE_NAME"
  fi

  set -x
}

function do_magento_build_start_mysql() {
  apt-get update -qq -y
  DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install mysql-server
  mkdir -p /var/run/mysqld/
  chown -R "mysql:mysql" /var/run/mysqld/
  {
    echo "[mysqld]";
    echo "bind_address = 127.0.0.1"
  } > /etc/my.cnf
  mysqld_safe &
}

function do_magento_build_stop_mysql() {
  pkill mysqld
  apt-get purge -qq -y mysql-server
  rm -rf /var/lib/mysql
  apt-get auto-remove -qq -y
  apt-get clean
  rm -rf /var/lib/apt/lists/* /var/tmp/*
}

function do_magento_remove_config_template() {
  # Now that setup:upgrade has run and made us a config.php that contains the right modules, don't override the config.php again at runtime.
  if [ -f /etc/confd/conf.d/magento_config.php.toml ]; then
    rm /etc/confd/conf.d/magento_config.php.toml
  fi
}

function do_magento_copy_build_auth_to_app() {
  cp -p /home/build/.composer/auth.json /app
}

function do_install_sample_data() {
  do_magento_copy_build_auth_to_app
  as_code_owner "bin/magento sampledata:deploy"

  do_magento_move_compiled_assets_away_from_codebase
  do_magento_setup_upgrade
  do_magento_move_compiled_assets_back_to_codebase
  do_magento_create_web_writable_directories
}

function do_magento_download_magerun2() {
  mkdir -p /app/bin
  chown build:build /app/bin
  as_code_owner "wget -O n98-magerun2.phar https://files.magerun.net/n98-magerun2.phar" /app/bin
  chmod +x /app/bin/n98-magerun2.phar
}

function do_magento2_templating() {
  mkdir -p /app/app/etc/
  chown -R "${CODE_OWNER}:${CODE_GROUP}" /app/app/
  if [ "${APP_USER_LOCAL}" == "true" ]; then
    chown "${CODE_OWNER}:${CODE_GROUP}" /app/app/etc/env.php
  fi
}

function do_magento_catalog_image_resize() {
  as_user "bin/magento catalog:images:resize -vvv" "/app" "www-data"
}

function do_magento_echo_last_minute_reports() {
  find /app/var/report -type f -mmin -1 -print -exec cat {} \;
}

function do_magento_tail_logs() {
  tail -f --retry \
    /app/var/log/debug.log \
    /app/var/log/exception.log \
    /app/var/log/system.log
}

function do_magento_create_admin_user() {
  set +x
  if [ -z "${MAGENTO_ADMIN_USERNAME}" ] || [ -z "${MAGENTO_ADMIN_PASSWORD}" ]; then
    set -x
    return 0
  fi
  local SQL="SELECT 1 FROM admin_user WHERE username='$MAGENTO_ADMIN_USERNAME'"
  local HAS_ADMIN_USER=0
  set +e
  if [ -n "$DATABASE_PASSWORD" ]; then
    echo "$SQL" | mysql -h"$DATABASE_HOST" -u"$DATABASE_USER" -p"$DATABASE_PASSWORD" "$DATABASE_NAME" | grep -q 1
    HAS_ADMIN_USER="$?"
  else
    echo "$SQL" | mysql -h"$DATABASE_HOST" -u"$DATABASE_USER" "$DATABASE_NAME" | grep -q 1
    HAS_ADMIN_USER="$?"
  fi
  set -e

  if [ "$HAS_ADMIN_USER" != 0 ]; then
    set +x
    as_code_owner "bin/magento admin:user:create \
      --admin-user='${MAGENTO_ADMIN_USERNAME}' \
      --admin-password='${MAGENTO_ADMIN_PASSWORD}' \
      --admin-email='${MAGENTO_ADMIN_EMAIL}' \
      --admin-firstname='Development' \
      --admin-lastname='Admin'"
    set -x
  fi
}

function do_magento2_build() {

  do_magento_build_start_mysql
  do_magento_create_web_writable_directories
  do_magento_frontend_build
  do_magento_assets_download
  do_magento_assets_install
  do_magento_install_custom

  DATABASE_HOST="localhost" DATABASE_USER="root" DATABASE_PASSWORD="" DATABASE_ROOT_PASSWORD="" MAGENTO_ENABLE_CACHE="false" MAGENTO_USE_REDIS="false" MAGENTO_HTTP_CACHE_HOSTS="" do_templating
  DATABASE_HOST="localhost" DATABASE_USER="root" DATABASE_PASSWORD="" DATABASE_ROOT_PASSWORD="" DATABASE_USER_HOST="localhost" MAGENTO_ENABLE_CACHE="false" MAGENTO_USE_REDIS="false" MAGENTO_HTTP_CACHE_HOSTS="" do_magento_database_install
  DATABASE_HOST="localhost" DATABASE_USER="root" DATABASE_PASSWORD="" DATABASE_ROOT_PASSWORD="" DATABASE_USER_HOST="localhost" MAGENTO_ENABLE_CACHE="false" MAGENTO_USE_REDIS="false" MAGENTO_HTTP_CACHE_HOSTS="" do_magento_installer_install
  DATABASE_HOST="localhost" DATABASE_USER="root" DATABASE_PASSWORD="" DATABASE_ROOT_PASSWORD="" DATABASE_USER_HOST="localhost" MAGENTO_ENABLE_CACHE="false" MAGENTO_USE_REDIS="false" MAGENTO_HTTP_CACHE_HOSTS="" do_replace_core_config_values
  do_magento_assets_cleanup

  do_magento_move_compiled_assets_away_from_codebase
  MAGENTO_ENABLE_CACHE="false" MAGENTO_USE_REDIS="false" MAGENTO_HTTP_CACHE_HOSTS="" do_magento_setup_upgrade
  do_magento_remove_config_template
  do_magento_move_compiled_assets_back_to_codebase

  do_magento_dependency_injection_compilation
  do_magento_deploy_static_content
  do_magento_install_finalise_custom
  do_magento_build_stop_mysql

  # Reset permissions to www-data:build for the var/log folder, which is owned by build:build after running bin/magento tasks as the build user!
  do_magento_create_web_writable_directories
}

function do_magento2_development_build() {
  if [[ "${IS_APP_MOUNTPOINT}" == "true" ]]; then
    do_magento_create_web_writable_directories
  fi
  if [[ "${MAGENTO_RUN_BUILD}" != "true" ]]; then
    # Ensure existing /app/app/etc/config.php isn't overwritten
    do_magento_remove_config_template
  fi
  if [[ "${MAGENTO_RUN_BUILD}" == "true" ]]; then
    do_magento_assets_download
    do_magento_assets_install
    do_templating
    do_magento2_setup
    do_magento_frontend_build
    do_magento_install_custom
    do_magento_dependency_injection_compilation
    set +e
    do_magento_deploy_static_content
    set -e
    do_magento_install_finalise_custom
    do_magento_remove_config_template
    do_magento_create_admin_user
    # Reset permissions to www-data:build for the var/log folder, which is owned by build:build after running bin/magento tasks as the build user!
    do_magento_create_web_writable_directories
  fi

  do_magento_install_development_custom
}

function do_magento2_setup() {
  do_magento_database_install
  do_magento_installer_install
  do_replace_core_config_values
  do_magento_cache_flush
  do_magento_setup_upgrade
  do_magento_cache_flush
  do_magento_reindex
}
