#!/bin/bash

set -e

source /usr/local/share/bootstrap/common_functions.sh

load_env

set -x

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi

cd /app || exit 1;

set +e
IS_CHOWN_FORBIDDEN="$(is_chown_forbidden)"
set -e


do_magento_install
