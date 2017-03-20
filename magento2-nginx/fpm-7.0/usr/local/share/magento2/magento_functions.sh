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
  rm -rf var/generation/*
  redis-cli -h "$REDIS_HOST" -p "$REDIS_HOST_PORT" -n "$MAGENTO_REDIS_CACHE_DATABASE" "FLUSHDB"
  redis-cli -h "$REDIS_HOST" -p "$REDIS_HOST_PORT" -n "$MAGENTO_REDIS_FULL_PAGE_CACHE_DATABASE" "FLUSHDB"
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
  if [ "$PRODUCTION_ENVIRONMENT" = "1" ]; then
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
  if [ "$IS_HEM" == 'true' ]; then
    export HEM_RUN_ENV="${HEM_RUN_ENV:-local}"
    for asset_env in $ASSET_DOWNLOAD_ENVIRONMENTS; do
      as_build "hem --non-interactive --skip-host-checks assets download -e $asset_env"
    done
  fi
}

function do_magento_cache_flush() {
  # Flush magento cache
  as_code_owner "bin/magento cache:flush"
}

function do_magento_create_web_writable_directories() {
  # Ensure the permissions are web writable for the assets and var folders, but only on filesystems that allow chown.
  if [ "$IS_CHOWN_FORBIDDEN" != 'true' ]; then
    chown -R "${APP_USER}:${APP_GROUP}" pub/media pub/static var
  fi
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
      mysql -h"$DATABASE_HOST" -uroot -p"$DATABASE_ROOT_PASSWORD" -e "DROP DATABASE IF EXISTS $DATABASE_NAME" || exit 1
    fi
  
    set +e
    mysql -h"$DATABASE_HOST" -u"$DATABASE_USER" -p"$DATABASE_PASSWORD" "$DATABASE_NAME" -e "SHOW TABLES; SELECT FOUND_ROWS() > 0;" | grep -q 1
    DATABASE_EXISTS=$?
    set -e
  
    if [ "$DATABASE_EXISTS" -ne 0 ]; then
      echo 'Create Magento database'
      echo "CREATE DATABASE IF NOT EXISTS $DATABASE_NAME ; GRANT ALL ON $DATABASE_NAME.* TO $DATABASE_USER@'%' IDENTIFIED BY '$DATABASE_PASSWORD' ; FLUSH PRIVILEGES" |  mysql -uroot -p"$DATABASE_ROOT_PASSWORD" -h"$DATABASE_HOST"
  
      echo 'zcating the magento database dump into the database'
      zcat "$DATABASE_ARCHIVE_PATH" | mysql -h"$DATABASE_HOST" -uroot -p"$DATABASE_ROOT_PASSWORD" "$DATABASE_NAME" || exit 1
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
      chown -R "${APP_USER}:${APP_GROUP}" pub/media
      chmod -R u+rw,o-rw pub/media
    else
      chmod -R a+rw pub/media
    fi
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
  INSERT INTO core_config_data VALUES (NULL, 'default', '0', 'system/full_page_cache/varnish/backend_host', 'varnish');
  INSERT INTO core_config_data VALUES (NULL, 'default', '0', 'system/full_page_cache/varnish/backend_port', '80');
  $ADDITIONAL_SETUP_SQL"
  
  echo "Running the following SQL on $DATABASE_HOST.$DATABASE_NAME:"
  echo "$SQL"
  
  echo "$SQL" | mysql -h"$DATABASE_HOST" -u"$DATABASE_USER" -p"$DATABASE_PASSWORD" "$DATABASE_NAME"
  set -x
}

function do_magento2_templating() {
  mkdir -p /app/app/etc/
  mkdir -p /home/build/.hem/gems/
  chown -R build:build /home/build/.hem/
}

function do_magento2_build() {
  do_magento_create_web_writable_directories
  do_magento_frontend_build
  do_magento_assets_download
  do_magento_assets_install
  do_magento_install_custom
}

function do_magento2_start() {
  # do_magento_switch_web_writable_directories_to_code_owner
  do_magento_dependency_injection_compilation
  do_magento_deploy_static_content
  # do_magento_create_web_writable_directories
  do_magento_install_finalise_custom
}

function do_magento2_development_build() {
  # do_magento_assets_download
  do_magento2_setup
  # do_magento_assets_install
  do_magento_install_development_custom
}

function do_magento2_setup() {
  do_magento_database_install
  do_replace_core_config_values
  do_magento_cache_flush
  do_magento_move_compiled_assets_away_from_codebase
  do_magento_setup_upgrade
  do_magento_move_compiled_assets_back_to_codebase
  do_magento_reindex
  do_magento_cache_flush
}
