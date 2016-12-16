#!/bin/bash

set -xe

source /usr/local/share/bootstrap/common_functions.sh

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi

cd /app || exit 1

set +e
is_nfs
IS_NFS=$?
set -e

as_code_owner "php /app/bin/n98-magerun.phar cache:clean config" /app/public
as_code_owner "php /app/bin/n98-magerun.phar sys:setup:incremental -n" /app/public

(as_code_owner "php /app/bin/n98-magerun.phar indexer:reindex" /app/public || echo "Failing indexing to the end, ignoring.") && echo "Indexing successful"

# Download and install the assets when running the image
# (sad that we have to do that tho...)

# Download the static assets
set +e
is_hem_project
set -e
IS_HEM=$?
if [ "$IS_HEM" -eq 0 ]; then
  export HEM_RUN_ENV="${HEM_RUN_ENV:-local}"
  for asset_env in $ASSET_DOWNLOAD_ENVIRONMENTS; do
    as_build "hem --non-interactive --skip-host-checks assets download -e $asset_env"
  done
  bash "$DIR/development/install_assets.sh"
fi

# Flush magento cache
as_code_owner "php bin/n98-magerun.phar cache:flush"

if [ -f "$DIR/install_magento_finalise_custom.sh" ]; then
  # shellcheck source=./install_magento_finalise_custom.sh
  source "$DIR/install_magento_finalise_custom.sh"
fi
