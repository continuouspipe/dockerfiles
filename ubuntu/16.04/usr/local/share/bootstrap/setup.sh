#!/bin/bash

source /usr/local/share/bootstrap/common_functions.sh

load_env

# Initialisation - Pre templating
source /usr/local/share/bootstrap/pre_templating.sh

# Initialisation - create a user to match the mountpoint's settings if told to
source /usr/local/share/bootstrap/trigger_update_permissions.sh

function do_confd() {
  # Initialisation - Templating
  confd -onetime -backend env
}
