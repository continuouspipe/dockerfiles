#!/bin/bash

source /usr/local/share/bootstrap/common_functions.sh

load_env

do_confd() {
  # Initialisation - Templating
  bash -c "$(transform_env_variables_for_confd) confd -onetime -backend env"
}

do_templating() {
  do_confd
}

do_supervisord() {
  exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
}

do_start_supervisord() {
  do_start
  do_supervisord
}

do_start_exec() {
  do_start
  exec "$@"
}
