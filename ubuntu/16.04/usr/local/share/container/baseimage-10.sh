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

do_build_user_ssh_keys() {
  echo "Setting up SSH keys for the build user"
  set +x
  if [ -n "$BUILD_USER_SSH_PRIVATE_KEY" ] && [ -n "$BUILD_USER_SSH_PUBLIC_KEY" ]; then
    mkdir -p /home/build/.ssh/
    echo "$BUILD_USER_SSH_PRIVATE_KEY" | base64 --decode > /home/build/.ssh/id_rsa
    echo "$BUILD_USER_SSH_PUBLIC_KEY" | base64 --decode > /home/build/.ssh/id_rsa.pub
    chown -R build:build /home/build/.ssh/
    chmod 600 /home/build/.ssh/id_rsa /home/build/.ssh/id_rsa.pub
    unset BUILD_USER_SSH_PRIVATE_KEY
    unset BUILD_USER_SSH_PUBLIC_KEY
  fi
  set -x
}
