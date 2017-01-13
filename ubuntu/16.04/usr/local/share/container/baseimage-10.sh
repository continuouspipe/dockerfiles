#!/bin/bash

do_update_permissions()
{
  if [ "${APP_USER_LOCAL}" == "true" ]; then
    source /usr/local/share/bootstrap/update_permissions.sh
    update_permissions "${WORK_DIRECTORY}"
  fi
}

alias_function do_start do_ubuntu_start_inner
do_start() {
    do_ubuntu_start_inner
    do_update_permissions
    check_development_start
    do_templating
}

check_development_start() {
  if [ "$DEVELOPMENT_MODE" -eq 0 ]; then
    do_development_start
  fi
}

do_development_start() {
  :
}
