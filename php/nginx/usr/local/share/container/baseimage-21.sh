#!/bin/bash

# BC for if a sub-image extends do_nginx
alias_function do_webserver do_nginx
do_webserver() {
  do_nginx
}

do_webserver_reload() {
  supervisor_signal HUP nginx
}

alias_function do_build do_nginx_build_inner
do_build() {
  do_phpfpm_named_pipe
  do_nginx_build_inner
}

alias_function do_start do_nginx_start_inner
do_start() {
  do_nginx_start_inner
  do_phpfpm_named_pipe
}

do_phpfpm_named_pipe() {
  if [ ! -p /var/log/php-fpm/stdout ]; then
    if [ -e /var/log/php-fpm/stdout ]; then
      rm -f /var/log/php-fpm/stdout
    fi
    mkdir -p /var/log/php-fpm/
    mkfifo -m 0660 /var/log/php-fpm/stdout
  fi
  chown -R "$APP_USER:$APP_GROUP" /var/log/php-fpm/
}

do_tail_phpfpm_logs()
{
  cat 0<> /var/log/php-fpm/stdout
}
