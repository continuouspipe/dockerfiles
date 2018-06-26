#!/bin/bash

set -e

extract_latest()
{
  local SERVICE="$1"
  mkdir -p /tmp/latest
  for attempt in $(seq 0 2); do
    echo "Attempt ${attempt} to extract latest archive:"
    if tar --directory /tmp/latest --exclude-from=/app/exclusions.txt --anchored --wildcards --extract --file "/tmp/archives/${SERVICE}_latest.tar"; then
      break
    else
      continue
    fi
  done
}

extract_stable()
{
  local SERVICE="$1"
  mkdir -p /tmp/stable
  for attempt in $(seq 0 2); do
    echo "Attempt ${attempt} to extract stable archive:"
    if tar --directory /tmp/stable --exclude-from=/app/exclusions.txt --anchored --wildcards --extract --file "/tmp/archives/${SERVICE}_stable.tar"; then
      break
    else
      continue
    fi
  done
}

run_diff()
(
  set +e
  local RETURN_VALUE=0
  colordiff --recursive --suppress-common-lines --ignore-all-space --no-dereference \
    /tmp/stable /tmp/latest
  RETURN_VALUE=$(( RETURN_VALUE + $? ))
  if [ -d "/tmp/stable/etc/confd/" ] || [ -d "/tmp/latest/etc/confd/" ]; then
    colordiff --recursive --suppress-common-lines --ignore-all-space --no-dereference \
      /tmp/stable/etc/confd/ /tmp/latest/etc/confd/
    RETURN_VALUE=$(( RETURN_VALUE + $? ))
  fi
  if [ -d "/tmp/stable/usr/local/" ] || [ -d "/tmp/latest/usr/local/" ]; then
    colordiff --recursive --suppress-common-lines --ignore-all-space --no-dereference \
      /tmp/stable/usr/local/ /tmp/latest/usr/local/
    RETURN_VALUE=$(( RETURN_VALUE + $? ))
  fi
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
