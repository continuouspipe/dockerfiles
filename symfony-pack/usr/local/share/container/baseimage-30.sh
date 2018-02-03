#!/bin/bash

source /usr/local/share/symfony/symfony_pack_functions.sh

alias_function do_build do_symfony_pack_build_inner
do_build() {
  do_symfony_pack_build_inner
  do_symfony_pack_build
}
