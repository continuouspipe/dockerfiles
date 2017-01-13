#!/bin/bash

load_env() {
  set +x
  shopt -s nullglob
  set -- /usr/local/share/env/*
  if [ "$#" -gt 0 ]; then
    for file in "$@"; do
      # shellcheck source=/dev/null
      source "${file}"
    done
  fi
  set -x
}

as_user() {
  local COMMAND="$1"
  local WORKING_DIR="$2"
  local USER="$3"
  if [ -z "$COMMAND" ]; then
    return 1;
  fi
  if [ -z "$WORKING_DIR" ]; then
    WORKING_DIR='/app';
  fi
  if [ -z "$USER" ]; then
    USER='build';
  fi

  sudo -u "$USER" -E HOME="$(getent passwd "$USER" | cut -d: -f 6)" /bin/bash -c "cd '$WORKING_DIR'; $COMMAND"
}

as_build() {
  as_user "$1" "$2" 'build'
}

as_code_owner() {
  as_user "$1" "$2" "$CODE_OWNER"
}

is_hem_project() {
  if [ -f /app/tools/hem/config.yaml ] || [ -f /app/tools/hobo/config.yaml ]; then
    return 0
  fi

  return 1
}

is_chown_supported() {
  # Determine if the app directory is an NFS mountpoint, which doesn't allow chowning.
  grep -q -E "/app (nfs|vboxsf)" /proc/mounts
  return $?
}

do_vboxsf_warning() {
  grep -q "/app vboxsf" /proc/mounts
  IS_VBOXSF="$?"
  if [ "$IS_VBOXSF" -eq 0 ]; then
    NON_WRITABLE_COUNT="$(find /app ! -perm /o+w | wc -l)"
    if [ "$NON_WRITABLE_COUNT" -ge 0 ]; then
      echo
      echo "Hello, it seems you are trying to run this image with a codebase mountpoint provided by Virtualbox. "
      echo
      echo "If trying to write files or directories to the codebase, you may encounter permissions issues."
      echo
      echo "For permissions to be correct for the codebase inside this docker container, please run "
      echo
      echo "'chmod a+rw /path/to/the/codebase/folder/that/needs/write/permissions'"
      echo
      echo "on your host filesystem, then stop and start this container."
      echo
    fi
  fi
}

alias_function() {
    local -r ORIG_FUNC=$(declare -f $1)
    local -r NEWNAME_FUNC="$2${ORIG_FUNC#$1}"
    eval "$NEWNAME_FUNC"
}

do_build() {
  :
}

do_start() {
  do_vboxsf_warning
}
