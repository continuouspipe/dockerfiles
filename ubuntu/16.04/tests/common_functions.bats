#!/usr/bin/env bats

load /usr/local/share/bats/helper.bash

# shellcheck source=../usr/local/share/bootstrap/common_functions.sh
source "$BATS_TEST_DIRNAME/../usr/local/share/bootstrap/common_functions.sh"

function setup() {
  function original() {
    echo "original"
  }
}

@test "escape_shell_args escapes spaces" {
  run escape_shell_args 'test test2'
  assert_success
  assert_output 'test\ test2 '
}

@test "escape_shell_args adds a space to the end of the string" {
  run escape_shell_args 'test'
  assert_success
  assert_output 'test '
}

@test "escape_shell_args escapes special characters" {
  run escape_shell_args '# &*{}[];,"\!?$<>|^`test'
  assert_success
  assert_output '\#\ \&\*\{\}\[\]\;\,\"\\\!\?\$\<\>\|\^\`test '

  run escape_shell_args "'test"
  assert_success
  assert_output "\'test "
}

@test "escape_shell_args does not escape non-special characters" {
  run escape_shell_args ":/.-+%~test"
  assert_success
  assert_output  ":/.-+%~test "
}

@test "resolve_path does not prepend the working path if the path begins with slash" {
  run resolve_path "/path" "/working"
  assert_success
  assert_output "/path"
}

@test "resolve_path prepends the working path if the path does not begin with slash" {
  run resolve_path "path" "/working"
  assert_success
  assert_output "/working/path"
}

@test "get_user_home_directory uses getent and cut" {
  stub getent 'passwd build : echo ":::::/home/foo:::::"'
  stub cut '-d: -f 6 : echo /home/foo'

  run get_user_home_directory "build"

  assert_success
  assert_output '/home/foo'

  unstub getent
  unstub cut
}

@test "get_user_home_directory returns if no user given" {
  run get_user_home_directory ""
  assert_failure
}

@test "get_user_home_directory finds the build user's home directory" {
  run get_user_home_directory "build"
  assert_success
  assert_output "/home/build"
}

@test "get_user_home_directory finds the www-data user's home directory" {
  run get_user_home_directory "www-data"
  assert_success
  assert_output "/var/www"
}

@test "get_user_home_directory finds the root user's home directory" {
  run get_user_home_directory "root"
  assert_success
  assert_output "/root"
}

@test "as_user runs a command via sudo" {
  stub sudo "-u build -E HOME=/home/build /bin/bash -c cd '/app'; test : true"
  unset get_user_home_directory
  stub get_user_home_directory "build : echo /home/build"

  run as_user 'test'

  assert_success
  unstub sudo
  unstub get_user_home_directory
}

@test "as_user runs a command via sudo from a certain directory" {
  stub sudo "-u build -E HOME=/home/build /bin/bash -c cd '/tmp'; test : true"
  unset get_user_home_directory
  stub get_user_home_directory "build : echo /home/build"

  run as_user "test" "/tmp"

  assert_success
  unstub sudo
  unstub get_user_home_directory
}

@test "as_user runs a command via sudo as a certain user" {
  stub sudo "-u www-data -E HOME=/var/www /bin/bash -c cd '/app'; test : true"
  unset get_user_home_directory
  stub get_user_home_directory "www-data : echo /var/www"

  run as_user "test" "/app" "www-data"

  assert_success
  unstub sudo
  unstub get_user_home_directory
}

@test 'as_build runs a command as the build user' {
  unset as_user
  stub as_user "ls  build : echo '. ..'"

  run as_build "ls"

  assert_success
  assert_output ". .."
  unstub as_user
}

@test 'as_build runs a command as the build user from a certain directory' {
  unset as_user
  stub as_user "ls /tmp build : true"

  run as_build "ls" "/tmp"

  assert_success
  unstub as_user
}

@test 'as_build does not vary the user based on CODE_OWNER' {
  unset as_user
  stub as_user "ls  build : true"

  CODE_OWNER="someone_else" run as_build "ls"

  assert_success
  unstub as_user
}

@test 'as_code_owner runs a command as the build user by default' {
  unset as_user
  stub as_user "ls  build : echo '. ..'"

  run as_code_owner "ls"

  assert_success
  assert_output ". .."
  unstub as_user
}

@test 'as_code_owner runs a command as the build user from a certain directory' {
  unset as_user
  stub as_user "ls /tmp build : true"

  run as_code_owner "ls" "/tmp"

  assert_success
  unstub as_user
}

@test 'as_code_owner varies the user based on CODE_OWNER' {
  unset as_user
  stub as_user "ls  someone_else : true"

  CODE_OWNER="someone_else" run as_code_owner "ls"

  assert_success
  unstub as_user
}

@test 'as_app_user varies the user based on APP_USER' {
  unset as_user
  stub as_user "ls /tmp someone_else : true"

  APP_USER="someone_else" run as_app_user "ls" "/tmp"

  assert_success
  unstub as_user
}

@test "alias_function renames a function" {
  export -f alias_function original
  run bash -c 'alias_function original aliased; aliased'
  assert_success
  assert_output "original"
}

@test "before prepends a function to another" {
  function prepended() {
    echo "prepended"
  }
  export -f before original prepended

  run bash -c 'before original prepended; original'
  assert_success
  [ "${lines[0]}" == "prepended" ]
  [ "${lines[1]}" == "original" ]
}

@test "after appends a function to another" {
  function appended() {
    echo "appended"
  }
  export -f after original appended

  run bash -c 'after original appended; original'

  assert_success
  [ "${lines[0]}" == "original" ]
  [ "${lines[1]}" == "appended" ]
}

@test "replace overwrites a function" {
  function replaced() {
    echo "replaced"
  }
  export -f replace original replaced
  run bash -c 'replace original replaced; original'
  assert_success
  [ "${lines[0]}" == "replaced" ]
}
