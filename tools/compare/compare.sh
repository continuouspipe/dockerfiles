#!/bin/bash

set -ex

extract_latest()
{
  local SERVICE="$1"
  mkdir -p /tmp/latest
  tar --directory /tmp/latest --exclude-from=/app/exclusions.txt --anchored --wildcards --extract --file "/tmp/archives/${SERVICE}_latest.tar"
}

extract_stable()
{
  local SERVICE="$1"
  mkdir -p /tmp/stable
  tar --directory /tmp/stable --exclude-from=/app/exclusions.txt --anchored --wildcards --extract --file "/tmp/archives/${SERVICE}_stable.tar"
}

run_diff()
(
  set +e
  colordiff --recursive --suppress-common-lines --ignore-all-space --no-dereference \
    /tmp/stable /tmp/latest
  colordiff --recursive --suppress-common-lines --ignore-all-space --no-dereference \
    /tmp/stable/etc/ /tmp/latest/etc/
  colordiff --recursive --suppress-common-lines --ignore-all-space --no-dereference \
    /tmp/stable/usr/local/ /tmp/latest/usr/local/
)

main()
{
  local SERVICE="$1"
  extract_latest "$SERVICE"
  extract_stable "$SERVICE"
  run_diff || true
}

main "$@"
