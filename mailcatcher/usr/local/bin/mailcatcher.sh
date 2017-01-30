#!/bin/bash
export HTTP_PORT=${HTTP_PORT:-1080}
export SMTP_PORT=${SMTP_PORT:-1025}

exec mailcatcher --foreground --ip=0.0.0.0 "--smtp-port=$SMTP_PORT" "--http-port=$HTTP_PORT" --no-quit
