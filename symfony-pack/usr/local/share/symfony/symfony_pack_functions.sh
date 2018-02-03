#!/bin/bash

source /usr/local/share/symfony/symfony_functions.sh

do_symfony_pack_build() {
  do_symfony_pack_encore_assets
}

do_symfony_pack_encore_assets() {
  if [ -f "yarn.lock" ]; then
    yarn install

    if grep -q "symfony/webpack-encore" yarn.lock; then
      npx encore production
    fi
  fi
}
