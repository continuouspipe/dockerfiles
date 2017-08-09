#!/bin/bash

source /usr/local/share/ez/ez_functions.sh

function do_setup() {
  ASSETS_FILES_ENABLED="false" do_assets_all
  do_ez_setup
}

alias_function do_development_start do_ez_development_start_inner
function do_development_start() {
  do_ez_development_start_inner
  do_setup
}
