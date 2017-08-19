#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/../usr/local/share/bootstrap/common_functions.sh"

function setup() {
  function original() {
    echo "original"
  }
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
