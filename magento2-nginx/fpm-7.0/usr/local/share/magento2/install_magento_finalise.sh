#!/bin/bash

set -xe

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi ;

source "$DIR/common_functions.sh"
bin/magento setup:upgrade

# Compile the DIC if to be productionized
if [ "$PRODUCTION_ENVIRONMENT" = "1" ]; then
  bin/magento setup:di:compile
fi

(bin/magento indexer:reindex || echo "Failing indexing to the end, ignoring.") && echo "Indexing successful"

# Download and install the assets when running the image
# (sad that we have to do that tho...)

# Download the static assets
set +e
is_hem_project
set -e
IS_HEM=$?
if [ "$IS_HEM" -eq 0 ]; then
  export HEM_RUN_ENV="${HEM_RUN_ENV:-local}"
  as_build "hem --non-interactive --skip-host-checks assets download"
  bash "$DIR/development/install_assets.sh"
fi

set +e
is_nfs
IS_NFS=$?
set -e

# Ensure the permissions are web writable for the assets and var folders, but only on filesystems that allow chown.
if [ "$IS_NFS" -ne 0 ]; then
  chown -R www-data:www-data pub/media pub/static var
fi

# Flush magento cache
cd /app
bin/magento cache:flush
