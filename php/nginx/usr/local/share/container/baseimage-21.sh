#!/bin/bash

# BC for if a sub-image extends do_nginx
alias_function do_webserver do_nginx
do_webserver() {
  do_nginx
}
