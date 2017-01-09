#!/bin/bash

alias_function do_composer do_symfony_composer_inner
do_composer() {
  mkdir -p /app/var

  if [ "$IS_NFS" -ne 0 ]; then
    # Fix permissions so the web server user can write to /app/var for symfony cache files
    chown -R "$CODE_OWNER:$CODE_GROUP" /app
    chown -R "$CODE_OWNER:$APP_GROUP" /app/var
    chmod -R ug+rw,o-rw /app/var
  else
    chmod -R a+rw /app/var
  fi

  do_symfony_composer_inner
}
