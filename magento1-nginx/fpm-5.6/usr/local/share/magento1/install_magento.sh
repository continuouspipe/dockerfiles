#!/bin/bash

set -xe

source /usr/local/share/bootstrap/common_functions.sh
source /usr/local/share/php/common_functions.sh

load_env

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi

function do_composer() {
  run_composer
}

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

function do_magento_custom() {
  if [ -f "$DIR/install_magento_custom.sh" ]; then
    # shellcheck source=./install_magento_custom.sh
    source "$DIR/install_magento_custom.sh"
  fi
}

function do_magento_build() {
  do_composer
  do_magento_n98_download
  do_magento_create_directories
  do_magento_directory_permissions
  do_magento_frontend_build
  do_magento_custom
}
