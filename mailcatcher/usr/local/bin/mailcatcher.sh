#!/bin/bash

# Work around where if there is a service named "http" or "smtp", the HTTP_PORT/SMTP_PORT will be "tcp://<ip>:<port>"
# rather than just the port number
if [[ "$HTTP_PORT" =~ "tcp://" ]]; then
  HTTP_PORT="1080"
fi

if [[ "$SMTP_PORT" =~ "tcp://" ]]; then
  SMTP_PORT="1025"
fi

HTTP_HOST_PORT=${HTTP_HOST_PORT:-${HTTP_PORT:-1080}}
SMTP_HOST_PORT=${SMTP_HOST_PORT:-${SMTP_PORT:-1025}}

function check_valid_port() {
  local VAR_NAME="$1"
  local PORT="${!VAR_NAME}"
  if [[ "$PORT" =~ [^0-9] ]] || [[ "$PORT" -lt 1 ]] || [[ "$PORT" -gt 65535 ]]; then
    echo "Invalid Port specified for $VAR_NAME: '$PORT'"
    exit 1
  fi
}

check_valid_port "HTTP_HOST_PORT"
check_valid_port "SMTP_HOST_PORT"
export HTTP_HOST_PORT
export SMTP_HOST_PORT

exec mailcatcher --foreground --ip=0.0.0.0 "--smtp-port=$SMTP_HOST_PORT" "--http-port=$HTTP_HOST_PORT" --no-quit
