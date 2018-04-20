#!/bin/bash

set -e

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
  local RETURN_VALUE=0
  colordiff --recursive --suppress-common-lines --ignore-all-space --no-dereference \
    /tmp/stable /tmp/latest
  RETURN_VALUE=$(( RETURN_VALUE + $? ))
  colordiff --recursive --suppress-common-lines --ignore-all-space --no-dereference \
    /tmp/stable/etc/confd/ /tmp/latest/etc/confd/
  RETURN_VALUE=$(( RETURN_VALUE + $? ))
  colordiff --recursive --suppress-common-lines --ignore-all-space --no-dereference \
    /tmp/stable/usr/local/ /tmp/latest/usr/local/
  RETURN_VALUE=$(( RETURN_VALUE + $? ))
  return "$RETURN_VALUE"
)

main()
(
  local SERVICE="$1"
  extract_latest "$SERVICE"
  extract_stable "$SERVICE"
  echo "____Comparing ${SERVICE}____"
  set +e
  run_diff
  return "$?"
)

main "$@"
