#!/bin/bash

alias_function do_start do_ubuntu_start_inner
do_start() {
    do_ubuntu_start_inner
    check_development_start
    do_confd
    do_supervisord
}

check_development_start() {
  if [ "$DEVELOPMENT_MODE" -eq 0 ]; then
    do_development_start
  fi
}

do_development_start() {
  :
}
