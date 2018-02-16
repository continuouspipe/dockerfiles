#!/bin/bash

# BC for if a sub-image extends do_apache
alias_function do_webserver do_apache
do_webserver() {
  do_apache
}

do_webserver_reload() {
  supervisor_signal USR1 apache
}
