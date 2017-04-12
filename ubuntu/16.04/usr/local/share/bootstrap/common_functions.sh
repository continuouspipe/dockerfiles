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
}

get_user_home_directory() {
  local USER="$1"
  if [ -z "$USER" ]; then
    return 1
  fi
  getent passwd "$USER" | cut -d: -f 6
}

as_user() {
  set +x
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
  USER_HOME="$(get_user_home_directory "$USER")"
  set -x
  sudo -u "$USER" -E HOME="$USER_HOME" /bin/bash -c "cd '$WORKING_DIR'; $COMMAND"
}

as_build() {
  set +x
  as_user "$1" "$2" 'build'
}

as_code_owner() {
  set +x
  as_user "$1" "$2" "$CODE_OWNER"
}

as_app_user() {
  set +x
  as_user "$1" "$2" "$APP_USER"
}

convert_exit_code_to_string() {
  if [ "$1" -eq 0 ]; then
    echo 'true';
  else
    echo 'false';
  fi
}

convert_to_boolean_string() {
  if [ "$1" == '1' ] || [ "$1" == "true" ]; then
    echo 'true';
  else
    echo 'false';
  fi
}

transform_env_variables_for_confd() {
  local VARIABLES
  VARIABLES="$(env | grep -v "^START_" | egrep '=false$')"
  echo "${VARIABLES//=false/=}"
}

is_hem_project() {
  local RESULT=1
  if [ -f /app/tools/hem/config.yaml ] || [ -f /app/tools/hobo/config.yaml ]; then
    RESULT=0
  fi
  convert_exit_code_to_string "$RESULT"
  return $RESULT
}

is_app_mountpoint() {
  grep -q -E "/app (nfs|vboxsf|fuse\.osxfs)" /proc/mounts
  local RESULT="$?"
  convert_exit_code_to_string "$RESULT"
  return "$RESULT"
}

is_chown_forbidden() {
  # Determine if the app directory is an NFS mountpoint, which doesn't allow chowning.
  grep -q -E "/app (nfs|vboxsf)" /proc/mounts
  local RESULT="$?"
  convert_exit_code_to_string "$RESULT"
  return "$RESULT"
}

is_vboxsf_mountpoint() {
  grep -q "/app vboxsf" /proc/mounts
  local RESULT="$?"
  convert_exit_code_to_string "$RESULT"
  return "$RESULT"
}

alias_function() {
  local -r ORIG_FUNC=$(declare -f "$1")
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

  local SSH_USER_HOME
  SSH_USER_HOME=$(get_user_home_directory "$SSH_USER")

  if [ -n "$SSH_PRIVATE_KEY" ]; then
    echo "Setting up SSH keys for the $SSH_USER user"
    (
      umask 0077
      mkdir -p "$SSH_USER_HOME/.ssh/"
      echo "$SSH_PRIVATE_KEY" | base64 --decode > "$SSH_USER_HOME/.ssh/$SSH_FILENAME"
    )
    if [ -n "$SSH_PUBLIC_KEY" ]; then
      echo "$SSH_PUBLIC_KEY" | base64 --decode > "$SSH_USER_HOME/.ssh/$SSH_FILENAME.pub"
    fi
    if [ -n "$SSH_KNOWN_HOSTS" ]; then
      echo "$SSH_KNOWN_HOSTS" | base64 --decode > "$SSH_USER_HOME/.ssh/known_hosts"
    fi
    chown -R "$SSH_USER" "$SSH_USER_HOME/.ssh/"
    unset SSH_PRIVATE_KEY
    unset SSH_PUBLIC_KEY
    unset SSH_KNOWN_HOSTS
  fi
  set -x
}
