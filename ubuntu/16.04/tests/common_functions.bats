#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/../usr/local/share/bootstrap/common_functions.sh"

function setup() {
  function original() {
    echo "original"
  }
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
  COMMAND=''
  function sudo() {
    COMMAND="$@"
  }
  function get_user_home_directory() {
    echo "/home/build"
  }
  run as_user "test"
  [ "$status" -eq 0 ]
  [ "$COMMAND" == "sudo -u build -E HOME=/home/build bash -c \"cd '/app'; test\"" ]
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
