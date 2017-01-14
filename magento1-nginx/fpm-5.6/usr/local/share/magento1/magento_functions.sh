#!/bin/bash

function do_magento_n98_download() {
  if [ ! -f bin/n98-magerun.phar ]; then
    as_code_owner "curl -o bin/n98-magerun.phar https://files.magerun.net/n98-magerun.phar"
  fi
}

function do_magento_create_directories() {
  mkdir -p /app/public/media /app/public/sitemaps /app/public/staging /app/public/var
}

function do_magento_directory_permissions() {
  if [ "$IS_CHOWN_FORBIDDEN" -ne 0 ]; then
    chown -R "${APP_USER}:${CODE_GROUP}" /app/public/media /app/public/sitemaps /app/public/staging /app/public/var
    chmod -R ug+rw,o-w /app/public/media /app/public/sitemaps /app/public/staging /app/public/var
    chmod -R a+r /app/public/media /app/public/sitemaps /app/public/staging
  else
    chmod -R a+rw /app/public/media /app/public/sitemaps /app/public/staging /app/public/var
  fi
}

function do_magento_frontend_build() {
  if [ -d "$FRONTEND_INSTALL_DIRECTORY" ]; then
    mkdir -p pub/static/frontend/

    if [ -d "pub/static/frontend/" ] && [ "$IS_CHOWN_FORBIDDEN" -ne 0 ]; then
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

    if [ -d "pub/static/frontend/" ] && [ "$IS_CHOWN_FORBIDDEN" -ne 0 ]; then
      chown -R "${APP_USER}:${APP_GROUP}" pub/static/frontend/
    fi
  fi
}

function do_magento_assets_download() {
  # Download the static assets
  if [ "$IS_HEM" -eq 0 ]; then
    for asset_env in $ASSET_DOWNLOAD_ENVIRONMENTS; do
      as_build "hem --non-interactive --skip-host-checks assets download -e $asset_env"
    done
    bash "$DIR/development/install_assets.sh"
  fi
}

function do_magento_assets_install() {
  if [ -f "$ASSET_ARCHIVE_PATH" ]; then
    if [ "$IS_CHOWN_FORBIDDEN" -ne 0 ]; then
      chown -R "${CODE_OWNER}:${CODE_GROUP}" /app/public/media
    else
      chmod -R a+rw /app/public/media
    fi

    echo 'extracting media files'
    as_code_owner "tar --no-same-owner --extract --strip-components=2 --touch --overwrite --gzip --file=$ASSET_ARCHIVE_PATH || exit 1" public/media

    if [ "$IS_CHOWN_FORBIDDEN" -ne 0 ]; then
      chown -R "${APP_USER}:${APP_GROUP}" /app/public/media
      chmod -R u+rw,go-w,go+r /app/public/media
    else
      chmod -R a+rw /app/public/media
    fi
  fi
}

function do_magento_database_install() {
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
}

function do_replace_core_config_values() {
  echo "DELETE from core_config_data WHERE path LIKE 'web/%base_url';
  DELETE from core_config_data WHERE path LIKE 'system/full_page_cache/varnish%';
  INSERT INTO core_config_data VALUES (NULL, 'default', '0', 'web/unsecure/base_url', '$PUBLIC_ADDRESS');
  INSERT INTO core_config_data VALUES (NULL, 'default', '0', 'web/secure/base_url', '$PUBLIC_ADDRESS');
  INSERT INTO core_config_data VALUES (NULL, 'default', '0', 'system/full_page_cache/varnish/access_list', 'varnish');
  INSERT INTO core_config_data VALUES (NULL, 'default', '0', 'system/full_page_cache/varnish/backend_host', 'varnish');
  INSERT INTO core_config_data VALUES (NULL, 'default', '0', 'system/full_page_cache/varnish/backend_port', '80');
  $ADDITIONAL_SETUP_SQL" |  mysql -h"$DATABASE_HOST" -u"$DATABASE_USER" -p"$DATABASE_PASSWORD" "$DATABASE_NAME"
}

function do_magento_cache_clean() {
  as_code_owner "php /app/bin/n98-magerun.phar cache:clean config" /app/public
}

function do_magento_system_setup() {
  as_code_owner "php /app/bin/n98-magerun.phar sys:setup:incremental -n" /app/public
}

function do_magento_reindex() {
  (as_code_owner "php /app/bin/n98-magerun.phar index:reindex:all" /app/public || echo "Failing indexing to the end, ignoring.") && echo "Indexing successful"
}

function do_magento_cache_flush() {
  # Flush magento cache
  as_code_owner "php bin/n98-magerun.phar cache:flush"
}

function do_magento_build_finalise() {
  do_magento_cache_clean
  do_magento_system_setup
  do_magento_reindex
  do_magento_assets_download
  do_magento_assets_install
  do_magento_cache_flush
}

function do_magento_build() {
  do_magento_n98_download
  do_magento_create_directories
  do_magento_directory_permissions
  do_magento_frontend_build
  do_magento_assets_download
}

function do_magento_development_build() {
  do_replace_core_config_values
  do_magento_assets_download
  do_magento_database_install
  do_replace_core_config_values
  do_magento_assets_install
}
