#!/bin/bash

function do_setup() {
  do_ez_setup
}

alias_function do_development_start do_ez_development_start_inner
function do_development_start() {
  do_ez_development_start_inner
  do_setup
}
