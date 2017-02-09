#!/bin/bash

source /usr/local/share/nginx/nginx_functions.sh

alias_function do_start do_nginx_start_inner
do_start() {
  do_nginx
  do_nginx_start_inner
}
