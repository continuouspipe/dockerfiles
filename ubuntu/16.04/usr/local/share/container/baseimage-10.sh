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

alias_function do_build do_ubuntu_build_inner
do_build() {
  do_build_user_ssh_keys
  do_ubuntu_build_inner
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
  set +x
  if [ -n "$BUILD_USER_SSH_PRIVATE_KEY" ]; then
    echo "Setting up SSH keys for the build user"
    (
      umask 0077
      mkdir -p /home/build/.ssh/
      echo "$BUILD_USER_SSH_PRIVATE_KEY" | base64 --decode > /home/build/.ssh/id_rsa
    )
    if [ -n "$BUILD_USER_SSH_PUBLIC_KEY" ]; then
      echo "$BUILD_USER_SSH_PUBLIC_KEY" | base64 --decode > /home/build/.ssh/id_rsa.pub
    fi
    if [ -n "$BUILD_USER_SSH_KNOWN_HOSTS" ]; then
      echo "$BUILD_USER_SSH_KNOWN_HOSTS" | base64 --decode > /home/build/.ssh/known_hosts
    fi
    chown -R build:build /home/build/.ssh/
    unset BUILD_USER_SSH_PRIVATE_KEY
    unset BUILD_USER_SSH_PUBLIC_KEY
    unset BUILD_USER_SSH_KNOWN_HOSTS
  fi
  set -x
}
