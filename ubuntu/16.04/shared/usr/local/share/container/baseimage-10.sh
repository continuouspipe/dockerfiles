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
    do_templating
    check_development_start
}

alias_function do_build do_ubuntu_build_inner
do_build() {
  do_build_user_ssh_keys
  do_ubuntu_build_inner
}

check_development_start() {
  if [ "$DEVELOPMENT_MODE" == 'true' ] && [ "$RUN_BUILD" == 'true' ]; then
    do_development_start
  fi
}

do_development_start() {
  :
}

do_build_user_ssh_keys() (
  set +x
  do_user_ssh_keys "build" "id_rsa" "$BUILD_USER_SSH_PRIVATE_KEY" "$BUILD_USER_SSH_PUBLIC_KEY" "$BUILD_USER_SSH_KNOWN_HOSTS"
  unset BUILD_USER_SSH_PRIVATE_KEY
  unset BUILD_USER_SSH_PUBLIC_KEY
  unset BUILD_USER_SSH_KNOWN_HOSTS
)

do_setup() {
  :
}

do_migrate() {
  :
}
