#!/bin/bash

do_ssh_forward_set_credentials() {
  if [ -n "${SSH_FORWARD_PASSWORD}" ]; then
    echo "forward:${SSH_FORWARD_PASSWORD}" | chpasswd
  fi

  if [ -n "${SSH_FORWARD_AUTHORIZED_KEYS}" ]; then
    (
      umask 0077
      mkdir /home/forward/.ssh
      echo "${SSH_FORWARD_AUTHORIZED_KEYS}" > /home/forward/.ssh/authorized_keys
    )
  fi
}

alias_function do_start do_ssh_forward_start_inner
do_start() {
  do_ssh_forward_set_credentials
  do_ssh_forward_start_inner
}