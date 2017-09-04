#!/bin/bash

escape_shell_args() {
   printf "%q " "$@"
}

resolve_path() {
  local -r PATH="$1"
  local -r WORKING_PATH="$2"

  case "${PATH}" in
  /*)
    echo "${PATH}"
    ;;
  *)
    echo "${WORKING_PATH}/${PATH}"
    ;;
  esac
}

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

as_user() (
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
)

as_build() (
  set +x
  as_user "$1" "$2" 'build'
)

as_code_owner() (
  set +x
  as_user "$1" "$2" "$CODE_OWNER"
)

as_app_user() (
  set +x
  as_user "$1" "$2" "$APP_USER"
)

convert_exit_code_to_string() {
  if [ "$1" -eq 0 ]; then
    echo 'true';
  else
    echo 'false';
  fi
}

run_return_boolean() {
  if "$@"; then
    echo 'true'
  else
    echo 'false'
  fi
}

convert_to_boolean_string() {
  if [ "$1" == '1' ] || [ "$1" == "true" ]; then
    echo 'true';
  else
    echo 'false';
  fi
}

convert_to_boolean_string_zero_is_true() {
  if [ "$1" == '0' ]; then
    echo 'true';
  elif [ "$1" == '1' ]; then
    echo 'false';
  else
    convert_to_boolean_string "$1"
  fi
}

is_true() {
  case "$1" in
  true|1)
    return 0;
    ;;
  esac
  return 1;
}

is_false() {
  case "$1" in
  true|1)
    return 1;
    ;;
  esac
  return 0;
}

is_hem_project() {
  [ -f /app/tools/hem/config.yaml ] || [ -f /app/tools/hobo/config.yaml ]
  return "$?"
}

is_app_mountpoint() {
  grep -q -E "/app (nfs|vboxsf|fuse\\.osxfs)" /proc/mounts
  return "$?"
}

is_chown_forbidden() {
  # Determine if the app directory is an NFS mountpoint, which doesn't allow chowning.
  grep -q -E "/app (nfs|vboxsf)" /proc/mounts
  return "$?"
}

is_vboxsf_mountpoint() {
  grep -q "/app vboxsf" /proc/mounts
  return "$?"
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


do_user_ssh_keys() (
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
)

function do_enable_tracing() {
  export PS4='$(date "+%s.%N ($LINENO) + ")'
}

function do_apt_get_update() {
  apt-get update -qq
}

function do_install_security_updates() {
  do_apt_get_update
  DEBIAN_FRONTEND=noninteractive apt-get -s dist-upgrade | grep "^Inst" | \
     grep -i securi | awk -F " " '{print $2}' | \
     xargs apt-get -qq -y --no-install-recommends install
  do_clear_apt_caches
}

function do_clear_apt_caches() {
  apt-get auto-remove -qq -y
  apt-get clean
  rm -rf /var/lib/apt/lists/*
}

function wait_for_remote_ports() (
  set +x

  local -r TIMEOUT=$1
  local -r INTERVAL=0.5
  local -r CHECK_TOTAL=$((TIMEOUT*2))
  local COUNT
  shift

  COUNT=0
  until (test_remote_ports "$@")
  do
    ((COUNT++)) || true
    if [ "${COUNT}" -gt "${CHECK_TOTAL}" ]
    then
      echo "One of the services [$*] didn't become ready in time"
      exit 1
    fi
    sleep "${INTERVAL}"
  done
)

function test_remote_ports() {
  local SERVICE
  local SERVICE_PARAMS

  for SERVICE in "$@"; do
    IFS=':'
    # shellcheck disable=SC2206
    SERVICE_PARAMS=($SERVICE)
    unset IFS

    timeout 1 bash -c "cat < /dev/null > /dev/tcp/${SERVICE_PARAMS[0]}/${SERVICE_PARAMS[1]}" 2>/dev/null || return 1
  done
}

function do_ownership() {
  local OWNERSHIP_PATH=($1)
  local USER="$2"
  local GROUP="$3"
  local ALLOW_GROUP_WRITE="${4:-true}"
  if [ "$IS_CHOWN_FORBIDDEN" != 'true' ]; then
    find "${OWNERSHIP_PATH[@]}" \( ! -user "${USER}" -or ! -group "${GROUP}" \) -exec chown "${USER}:${GROUP}" {} +
  fi
  do_read_write_permissions "${OWNERSHIP_PATH[@]}" "${ALLOW_GROUP_WRITE}"
}

function do_read_write_permissions() {
  local OWNERSHIP_PATH=($1)
  local ALLOW_GROUP_WRITE="${2:-true}"
  if [ "$IS_CHOWN_FORBIDDEN" != 'true' ]; then
    if [ "$ALLOW_GROUP_WRITE" == 'true' ]; then
      find "${OWNERSHIP_PATH[@]}" \( ! -perm /u=w -or ! -perm /g=w -or -perm /o=w \) -exec chmod ug+rw,o-w {} +
    else
      find "${OWNERSHIP_PATH[@]}" \( ! -perm /u=w -or -perm /g=w -or -perm /o=w \) -exec chmod u+rw,go-w {} +
    fi
  else
    find "${OWNERSHIP_PATH[@]}" \( ! -perm /u=w -or ! -perm /g=w -or ! -perm /o=w \) -exec chmod a+rw {} +
  fi
}

function do_read_permissions() {
  local OWNERSHIP_PATH=($1)
  find "${OWNERSHIP_PATH[@]}" \( ! -perm /u=r -or ! -perm /g=r -or ! -perm /o=r \) -exec chmod a+r {} +
}

function do_remove_other_permissions() {
  local OWNERSHIP_PATH=($1)
  find "${OWNERSHIP_PATH[@]}" \( -perm /o=r -or -perm /o=w -or -perm /o=x \) -exec chmod o-rwx {} +
}
