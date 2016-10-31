#!/bin/bash

set -xe

# Initialization
confd -onetime -backend env

# Start services
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
