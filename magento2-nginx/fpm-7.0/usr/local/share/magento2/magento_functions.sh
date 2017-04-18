#!/bin/bash

function do_composer_config() {
  as_code_owner "composer config repositories.magento composer https://repo.magento.com/"

  if [ -n "$MAGENTO_USERNAME" ] && [ -n "$MAGENTO_PASSWORD" ]; then
    as_code_owner "composer global config http-basic.repo.magento.com '$MAGENTO_USERNAME' '$MAGENTO_PASSWORD'"
  fi
  if [ -n "$COMPOSER_CUSTOM_CONFIG_COMMAND" ]; then
    as_code_owner "$COMPOSER_CUSTOM_CONFIG_COMMAND"
  fi
}

function do_composer_post_install() {
  chmod +x bin/magento
}

function do_magento_create_web_writable_directories() {
  mkdir -p pub/media pub/static var

  if [ "$IS_CHOWN_FORBIDDEN" != 'true' ]; then
    chown -R "${APP_USER}:${CODE_GROUP}" pub/media pub/static var
    chmod -R ug+rw,o-w pub/media pub/static var
  else
    chmod -R a+rw pub/media pub/static var
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
    chown -R "${CODE_OWNER}":"${CODE_GROUP}" pub/media pub/static var
  else
    chmod a+rw pub/media pub/static var
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
  if [ "$MAGENTO_USE_REDIS" = "true" ]; then
    redis-cli -h "$REDIS_HOST" -p "$REDIS_HOST_PORT" -n "$MAGENTO_REDIS_CACHE_DATABASE" "FLUSHDB"
    redis-cli -h "$REDIS_HOST" -p "$REDIS_HOST_PORT" -n "$MAGENTO_REDIS_FULL_PAGE_CACHE_DATABASE" "FLUSHDB"
  fi
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
    as_code_owner "bin/magento setup:static-content:deploy $FRONTEND_COMPILE_LANGUAGES"
  fi
}

function do_magento_reindex() {
  (as_code_owner "bin/magento indexer:reindex" || echo "Failing indexing to the end, ignoring.") && echo "Indexing successful"
}

function do_magento_assets_download() {
  if [ -n "$AWS_S3_BUCKET" ]; then
    for asset_env in $ASSET_DOWNLOAD_ENVIRONMENTS; do
      as_build "aws s3 cp 's3://${AWS_S3_BUCKET}/${asset_env}' 'tools/assets/${asset_env}' --recursive"
    done
  fi
}

function do_magento_cache_flush() {
  # Flush magento cache
  as_code_owner "bin/magento cache:flush"
}

function do_magento_install_finalise_custom() {
  if [ -f "/usr/local/share/magento2/install_magento_finalise_custom.sh" ]; then
    # shellcheck source=./install_magento_finalise_custom.sh
    source "/usr/local/share/magento2/install_magento_finalise_custom.sh"
  fi
}

function do_magento_database_install() {
  set +x
  if [ -f "$DATABASE_ARCHIVE_PATH" ]; then
    if [ "$FORCE_DATABASE_DROP" == 'true' ]; then
      echo 'Dropping the Magento DB if exists'
      if [ -n "$DATABASE_ROOT_PASSWORD" ]; then
        mysql -h"$DATABASE_HOST" -uroot -p"$DATABASE_ROOT_PASSWORD" -e "DROP DATABASE IF EXISTS $DATABASE_NAME" || exit 1
      else
        mysql -h"$DATABASE_HOST" -uroot -e "DROP DATABASE IF EXISTS $DATABASE_NAME" || exit 1
      fi
    fi
  
    set +e
    if [ -n "$DATABASE_PASSWORD" ]; then
      mysql -h"$DATABASE_HOST" -u"$DATABASE_USER" -p"$DATABASE_PASSWORD" "$DATABASE_NAME" -e "SHOW TABLES; SELECT FOUND_ROWS() > 0;" | grep -q 1
    else
      mysql -h"$DATABASE_HOST" -u"$DATABASE_USER" "$DATABASE_NAME" -e "SHOW TABLES; SELECT FOUND_ROWS() > 0;" | grep -q 1
    fi
    DATABASE_EXISTS=$?
    set -e
  
    if [ "$DATABASE_EXISTS" -ne 0 ]; then
      echo 'Create Magento database'
      if [ -n "$DATABASE_ROOT_PASSWORD" ]; then
        echo "CREATE DATABASE IF NOT EXISTS $DATABASE_NAME ; GRANT ALL ON $DATABASE_NAME.* TO $DATABASE_USER@'$DATABASE_USER_HOST' IDENTIFIED BY '$DATABASE_PASSWORD' ; FLUSH PRIVILEGES" |  mysql -uroot -p"$DATABASE_ROOT_PASSWORD" -h"$DATABASE_HOST"
      else
        echo "CREATE DATABASE IF NOT EXISTS $DATABASE_NAME ; GRANT ALL ON $DATABASE_NAME.* TO $DATABASE_USER@'$DATABASE_USER_HOST' IDENTIFIED BY '$DATABASE_PASSWORD' ; FLUSH PRIVILEGES" |  mysql -uroot -h"$DATABASE_HOST"
      fi
  
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
  find /app/tools/assets/ -type f ! -path "*${DATABASE_ARCHIVE_PATH}" -delete
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
  INSERT INTO core_config_data VALUES (NULL, 'default', '0', 'system/full_page_cache/varnish/backend_host', 'varnish');
  INSERT INTO core_config_data VALUES (NULL, 'default', '0', 'system/full_page_cache/varnish/backend_port', '80');
  $ADDITIONAL_SETUP_SQL"
  
  echo "Running the following SQL on $DATABASE_HOST.$DATABASE_NAME:"
  echo "$SQL"
  
  echo "$SQL" | mysql -h"$DATABASE_HOST" -u"$DATABASE_USER" -p"$DATABASE_PASSWORD" "$DATABASE_NAME"
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
  rm /etc/confd/conf.d/magento_config.php.toml
}

function do_magento2_templating() {
  mkdir -p /app/app/etc/
}

function do_magento2_build() {
  do_magento_build_start_mysql
  do_magento_create_web_writable_directories
  do_magento_frontend_build
  do_magento_assets_download
  do_magento_assets_install
  do_magento_install_custom
  do_magento_assets_cleanup

  DATABASE_HOST=localhost DATABASE_USER=root DATABASE_PASSWORD="" DATABASE_ROOT_PASSWORD="" MAGENTO_ENABLE_CACHE="" do_templating
  DATABASE_HOST=localhost DATABASE_USER=root DATABASE_PASSWORD="" DATABASE_ROOT_PASSWORD="" DATABASE_USER_HOST="localhost" do_magento_database_install

  do_magento_move_compiled_assets_away_from_codebase
  MAGENTO_USE_REDIS="false" do_magento_setup_upgrade
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
  do_magento_install_development_custom
}

function do_magento2_setup() {
  do_magento_database_install
  do_replace_core_config_values
  do_magento_cache_flush
  do_magento_setup_upgrade
  do_magento_reindex
}
