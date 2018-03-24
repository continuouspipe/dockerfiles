#!/bin/bash

# Initialisation - Declare variables and run pre-templating steps.
source /usr/local/share/bootstrap/setup.sh

# Initialisation - Runtime installation tasks
shopt -s nullglob
set -- /usr/local/share/container/baseimage-*
if [ "$#" -gt 0 ]; then
  for file in "$@"; do
    # shellcheck source=/dev/null
    source "${file}"
  done
fi

load_env

source /usr/local/share/container/plan.sh
if [ -e "$WORK_DIRECTORY/plan.sh" ]; then
  # shellcheck source=/dev/null
  source "$WORK_DIRECTORY/plan.sh"
fi
if [ -e "$WORK_DIRECTORY/plan.override.sh" ]; then
  # shellcheck source=/dev/null
  source "$WORK_DIRECTORY/plan.override.sh"
fi

FUNCTIONS="$(compgen -A function)"
for func in $FUNCTIONS; do
  # shellcheck disable=SC2163
  export -f "$func"
done
