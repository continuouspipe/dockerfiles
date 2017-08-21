#!/bin/bash

function do_run_tests() {
  find . -maxdepth 3 -type d -name "tests" -print -exec bats {} +
}

function do_watch_tests() (
  set +e
  while true; do
    find /app ! -path "*/.git/*" | entr -d container run_tests
  done
)
