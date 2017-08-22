#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/../usr/local/share/bootstrap/common_functions.sh"

function setup() {
  function original() {
    echo "original"
  }
}

function teardown() {
  for overridden in "$MOCKS $SPIES"; do
    restore_function "$overridden"
  done

  MOCKED=''
  SPIES=''
}

function original_function() {
  if [ "$(type -t "$1")" == 'function' ]; then
    eval "original_$(declare -f $1)"
  fi
}

function restore_function() {
  if [ "$(type -t "original_$1")" == 'function' ]; then
    FUNC=$(declare -f "original_$1")
    eval "${FUNC#original_}"
    eval "unset original_$1"
  else
    eval "unset $1"
  fi
}

MOCKS=''
function mock() {
  MOCKS="$MOCKS $1"
  original_function "$1"
  eval "$1() { echo $2; }"
}

SPIES=''
function spy() {
  SPIES="$SPIES $1"
  original_function "$1"
  eval "export COMMAND_$1=''"
  eval "$1() { export COMMAND_$1=\"\$@\"; }"
}

@test "escape_shell_args uses printf" {
  spy 'printf'
  run escape_shell_args 'test test2'
  [ "$status" -eq 0 ]
  [ "$COMMAND_printf" == '%q  test test2' ]
}

@test "escape_shell_args adds a space to the end of the string" {
  run escape_shell_args 'test'
  [ "$status" -eq 0 ]
  [ "$output" == 'test ' ]
}

@test "escape_shell_args escapes special characters" {
  run escape_shell_args '# &*{}[];,"\!?$<>|^`test'
  [ "$status" -eq 0 ]
  [ "$output" == '\#\ \&\*\{\}\[\]\;\,\"\\\!\?\$\<\>\|\^\`test ' ]

  run escape_shell_args "'test"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "\'test " ]
}

@test "escape_shell_args does not escape non-special characters" {
  run escape_shell_args ":/.-+%~test"
  [ "$status" -eq 0 ]
  [ "$output" == ":/.-+%~test " ]
}

@test "resolve_path does not prepend the working path if the path begins with slash" {
  run resolve_path "/path" "/working"
  [ "$status" -eq 0 ]
  [ "$output" == "/path" ]
}

@test "resolve_path prepends the working path if the path does not begin with slash" {
  run resolve_path "path" "/working"
  [ "$status" -eq 0 ]
  [ "$output" == "/working/path" ]
}

@test "get_user_home_directory uses getent and cut" {
  spy 'getent'
  spy 'cut'
  run get_user_home_directory "build"
  [ "$status" -eq 0 ]
  [ "$COMMAND_getent" == 'passwd build' ]
  [ "$COMMAND_cut" == '-d: -f6' ]
}

@test "get_user_home_directory returns if no user given" {
  run get_user_home_directory ""
  [ "$status" -eq 1 ]
}

@test "get_user_home_directory finds the build user's home directory" {
  run get_user_home_directory "build"
  [ "$status" -eq 0 ]
  [ "$output" == "/home/build" ]
}

@test "get_user_home_directory finds the www-data user's home directory" {
  run get_user_home_directory "www-data"
  [ "$status" -eq 0 ]
  [ "$output" == "/var/www" ]
}

@test "get_user_home_directory finds the root user's home directory" {
  run get_user_home_directory "root"
  [ "$status" -eq 0 ]
  [ "$output" == "/root" ]
}

@test "as_user runs a command via sudo" {
  spy 'sudo'
  mock 'get_user_home_directory' '/home/build'
  run as_user "test"
  [ "$status" -eq 0 ]
  [ "$COMMAND_sudo" == "-u build -E HOME=/home/build bash -c cd /app; test" ]
}

@test "as_user runs a command via sudo from a certain directory" {
  spy 'sudo'
  mock 'get_user_home_directory' '/home/build'
  run as_user "test" "/tmp"
  [ "$status" -eq 0 ]
  [ "$COMMAND_sudo" == "-u build -E HOME=/home/build bash -c cd /tmp; test" ]
}

@test "as_user runs a command via sudo as a certain user" {
  spy 'sudo'
  mock 'get_user_home_directory' '/var/www'
  run as_user "test" "/app" "www-data"
  [ "$status" -eq 0 ]
  [ "$COMMAND_sudo" == "sudo -u www-data -E HOME=/var/www bash -c cd /app; test" ]
}

@test "alias_function renames a function" {
  alias_function original aliased
  run aliased
  [ "$status" -eq 0 ]
  [ "$output" == "original" ]
}

@test "before prepends a function to another" {
  function prepended() {
    echo "prepended"
  }
  before original prepended
  run original
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "prepended" ]
  [ "${lines[1]}" == "original" ]
}

@test "after appends a function to another" {
  function appended() {
    echo "appended"
  }
  after original appended
  run original
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "original" ]
  [ "${lines[1]}" == "appended" ]
}

@test "replace overwrites a function" {
  function replaced() {
    echo "replaced"
  }
  replace original replaced
  run original
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "replaced" ]
}
