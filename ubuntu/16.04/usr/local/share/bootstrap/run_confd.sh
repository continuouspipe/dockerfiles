#!/bin/bash

# Initialisation - Declare custom environment variables
source /usr/local/share/env/custom_env_variables

# Initialisation - Declare default environment variables
source /usr/local/share/env/default_env_variables

# Initialisation - Declare variables used by scripts in the ubuntu base image
# to avoid undeclared variables!
source /usr/local/share/env/bootstrap_env_variables

# Initialisation - Pre templating
source /usr/local/share/bootstrap/pre_templating.sh

# Initialisation - create a user to match the mountpoint's settings if told to
source /usr/local/share/bootstrap/trigger_update_permissions.sh

# Initialisation - Templating
confd -onetime -backend env
