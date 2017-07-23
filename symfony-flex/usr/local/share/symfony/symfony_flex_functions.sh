#!/bin/bash

do_symfony_flex_build() {
  do_symfony_flex_encore_assets
}

do_symfony_flex_encore_assets() {
  yarn install
  npx encore production
}
