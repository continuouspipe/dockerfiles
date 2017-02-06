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

as_app_user() {
  as_user "$1" "$2" "$APP_USER"
}

is_hem_project() {
  if [ -f /app/tools/hem/config.yaml ] || [ -f /app/tools/hobo/config.yaml ]; then
    return 0
  fi

  return 1
}

is_app_mountpoint() {
  grep -q -E "/app (nfs|vboxsf|fuse\.osxfs)" /proc/mounts
  return $?
}

is_chown_forbidden() {
  # Determine if the app directory is an NFS mountpoint, which doesn't allow chowning.
  grep -q -E "/app (nfs|vboxsf)" /proc/mounts
  return $?
}

is_vboxsf_mountpoint() {
  grep -q "/app vboxsf" /proc/mounts
  return $?
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
  :
}


do_user_ssh_keys() {
  set +x
  local SSH_USER="$1"
  if [ -z "$SSH_USER" ]; then
    return 1;
  fi

  local SSH_FILENAME="$2"
  local SSH_PRIVATE_KEY="$3"
  local SSH_PUBLIC_KEY="$4"
  local SSH_KNOWN_HOSTS="$5"

  if [ -n "$SSH_PRIVATE_KEY" ]; then
    echo "Setting up SSH keys for the $SSH_USER user"
    (
      umask 0077
      mkdir -p "~$SSH_USER/.ssh/"
      echo "$SSH_PRIVATE_KEY" | base64 --decode > "~$SSH_USER/.ssh/$SSH_FILENAME"
    )
    if [ -n "$SSH_PUBLIC_KEY" ]; then
      echo "$SSH_PUBLIC_KEY" | base64 --decode > "~$SSH_USER/.ssh/$SSH_FILENAME.pub"
    fi
    if [ -n "$SSH_KNOWN_HOSTS" ]; then
      echo "$SSH_KNOWN_HOSTS" | base64 --decode > "~$SSH_USER/.ssh/known_hosts"
    fi
    chown -R build:build /home/build/.ssh/
    unset SSH_PRIVATE_KEY
    unset SSH_PUBLIC_KEY
    unset SSH_KNOWN_HOSTS
  fi
  set -x
}
