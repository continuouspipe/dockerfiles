#!/bin/bash
HTTP_PORT=${HTTP_PORT:-1080}
SMTP_PORT=${SMTP_PORT:-1025}
if [[ "$HTTP_PORT" =~ "tcp://" ]]; then
  HTTP_PORT="1080"
fi
if [[ "$SMTP_PORT" =~ "tcp://" ]]; then
  SMTP_PORT="1025"
fi
export HTTP_PORT
export SMTP_PORT

exec mailcatcher --foreground --ip=0.0.0.0 "--smtp-port=$SMTP_PORT" "--http-port=$HTTP_PORT" --no-quit
