#!/bin/bash

source /usr/local/share/symfony/symfony_flex_functions.sh

alias_function do_build do_symfony_flex_build_inner
do_build() {
  do_symfony_flex_build_inner
  do_symfony_flex_build
}