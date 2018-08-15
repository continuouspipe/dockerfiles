#!/bin/bash

function do_magento_n98_download() {
  if [ ! -f bin/n98-magerun.phar ]; then
    as_code_owner "mkdir -p bin"
    as_code_owner "curl -o bin/n98-magerun.phar https://files.magerun.net/n98-magerun.phar"
  fi
}

function do_magento_create_directories() {
  mkdir -p "${MAGE_ROOT}/media" "${MAGE_ROOT}/sitemaps" "${MAGE_ROOT}/staging" "${MAGE_ROOT}/var"
}

function do_magento_directory_permissions() {
  if [ "$IS_CHOWN_FORBIDDEN" != 'true' ]; then
    [ ! -e "${MAGE_ROOT}/app/etc/local.xml" ] || chown -R "${CODE_OWNER}:${APP_GROUP}" "${MAGE_ROOT}/app/etc/local.xml"
    chown -R "${APP_USER}:${CODE_GROUP}" "${MAGE_ROOT}/media" "${MAGE_ROOT}/sitemaps" "${MAGE_ROOT}/staging" "${MAGE_ROOT}/var"
    chmod -R ug+rw,o-w "${MAGE_ROOT}/media" "${MAGE_ROOT}/sitemaps" "${MAGE_ROOT}/staging" "${MAGE_ROOT}/var"
    chmod -R a+r "${MAGE_ROOT}/media" "${MAGE_ROOT}/sitemaps" "${MAGE_ROOT}/staging"
  else
    [ ! -e "${MAGE_ROOT}/app/etc/local.xml" ] || chmod a+r "${MAGE_ROOT}/app/etc/local.xml"
    chmod -R a+rw "${MAGE_ROOT}/media" "${MAGE_ROOT}/sitemaps" "${MAGE_ROOT}/staging" "${MAGE_ROOT}/var"
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

function do_replace_core_config_values() (
  set +x
  local SQL
  SQL="DELETE from core_config_data WHERE path LIKE 'web/%base_url';
  DELETE from core_config_data WHERE path LIKE 'system/full_page_cache/varnish%';
  INSERT INTO core_config_data VALUES (NULL, 'default', '0', 'web/unsecure/base_url', '$PUBLIC_ADDRESS_UNSECURE');
  INSERT INTO core_config_data VALUES (NULL, 'default', '0', 'web/secure/base_url', '$PUBLIC_ADDRESS_SECURE');
  INSERT INTO core_config_data VALUES (NULL, 'default', '0', 'system/full_page_cache/varnish/access_list', 'varnish');
  INSERT INTO core_config_data VALUES (NULL, 'default', '0', 'system/full_page_cache/varnish/backend_host', 'varnish');
  INSERT INTO core_config_data VALUES (NULL, 'default', '0', 'system/full_page_cache/varnish/backend_port', '80');
  $ADDITIONAL_SETUP_SQL"

  echo "Running the following SQL on $DATABASE_HOST.$DATABASE_NAME:"
  echo "$SQL"

  echo "$SQL" | mysql -h"$DATABASE_HOST" -u"$DATABASE_USER" -p"$DATABASE_PASSWORD" "$DATABASE_NAME"
)

function do_magento_config_cache_enable() {
  as_app_user "php /app/bin/n98-magerun.phar cache:enable config" "${MAGE_ROOT}"
}

function do_magento_config_cache_clean() {
  as_app_user "php /app/bin/n98-magerun.phar cache:clean config" "${MAGE_ROOT}"
}

function do_magento_system_setup() {
  as_app_user "php /app/bin/n98-magerun.phar sys:setup:incremental -n" "${MAGE_ROOT}"
}

function do_magento_reindex() {
  (as_app_user "php /app/bin/n98-magerun.phar index:reindex:all" "${MAGE_ROOT}" || echo "Failing indexing to the end, ignoring.") && echo "Indexing successful"
}

function do_magento_cache_flush() {
  # Flush magento cache
  as_app_user "php bin/n98-magerun.phar cache:flush"
}

function do_magento_create_admin_user() (
  if [ "$MAGENTO_CREATE_ADMIN_USER" != 'true' ]; then
    return 0
  fi

  # Create magento admin user
  set +e
  as_app_user "php /app/bin/n98-magerun.phar admin:user:list | grep -q '$MAGENTO_ADMIN_USERNAME'" "${MAGE_ROOT}"
  local HAS_ADMIN_USER=$?
  set -e
  if [ "$HAS_ADMIN_USER" != 0 ]; then
    set +x
    echo "Creating admin user '$MAGENTO_ADMIN_USERNAME'"
    SENSITIVE="true" as_app_user "php /app/bin/n98-magerun.phar admin:user:create '$MAGENTO_ADMIN_USERNAME' '$MAGENTO_ADMIN_EMAIL' '$MAGENTO_ADMIN_PASSWORD' '$MAGENTO_ADMIN_FORENAME' '$MAGENTO_ADMIN_SURNAME' Administrators" "${MAGE_ROOT}"
  fi
)

function do_magento_templating() {
  :
}

function do_magento_build() {
  do_magento_n98_download
  do_magento_create_directories
  do_magento_directory_permissions
  do_magento_frontend_build
}

function do_magento_development_build() {
  do_magento_setup
}

function do_magento_setup() {
  do_replace_core_config_values
  do_magento_config_cache_enable
  do_magento_config_cache_clean
  do_magento_system_setup
  do_magento_create_admin_user
  do_magento_reindex
  do_magento_cache_flush
}
