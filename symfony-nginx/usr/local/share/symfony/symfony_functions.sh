#!/bin/bash

do_symfony_config_create() {
  # Prepare a default parameters.yml. incenteev/parameters-handler can still update it
  [ ! -f /app/app/config/parameters.yml ] && echo 'parameters: {}' > /app/app/config/parameters.yml
}

do_symfony_directory_create() {
  if [ "$SYMFONY_MAJOR_VERSION" -eq 2 ]; then
    mkdir -p /app/app/{cache,logs}
  fi
  mkdir -p /app/app/config
  mkdir -p /app/var
}

do_symfony_build_permissions() {
  if [ "$IS_NFS" -ne 0 ]; then
    # Fix permissions so the web server user can write to cache and logs folders
    if [ "$SYMFONY_MAJOR_VERSION" -eq 2 ]; then
      chown -R "$APP_USER:$CODE_GROUP" /app/app/{cache,logs}
      chmod -R ug+rw,o-rwx /app/app/{cache,logs}
    fi
    chown -R "$APP_USER:$CODE_GROUP" /app/var
    chmod -R ug+rw,o-rwx /app/var
  else
    if [ "$SYMFONY_MAJOR_VERSION" -eq 2 ]; then
      chmod -R a+rw /app/app/{cache,logs}
    fi
    chmod -R a+rw /app/var
  fi
}

do_symfony_build() {
  do_symfony_directory_create
  do_symfony_config_create
}
