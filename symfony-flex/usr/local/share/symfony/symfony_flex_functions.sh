#!/bin/bash

do_symfony_flex_build() {
  do_symfony_flex_encore_assets
}

do_symfony_flex_encore_assets() {
  if [ -f "yarn.lock" ]; then
    yarn install

    if grep -q "symfony/webpack-encore" yarn.lock; then
      npx encore production
    fi
  fi
}
