#!/bin/bash

as_build() {
  local COMMAND="$1"
  local WORKING_DIR="$2"
  if [ -z "$COMMAND" ]; then
    return 1;
  fi
  if [ -z "$WORKING_DIR" ]; then
    WORKING_DIR='/app';
  fi

  su -l build -c "cd '$WORKING_DIR'; $COMMAND"
}

is_hem_project() {
  if [ -f /app/tools/hem/config.yaml ] || [ -f /app/tools/hobo/config.yaml ]; then
    return 0
  fi

  return 1
}
