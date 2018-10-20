#!/bin/bash

do_run_tests()
{
  set -o pipefail
  local SERVICE_NAME
  for server in nginx apache; do
    for version in 7.2 7.1 5.6; do
      SERVICE_NAME="web_${version/./_}_${server}"
      wait_for_remote_ports 60 "$SERVICE_NAME:443"
      curl --insecure --fail "https://$SERVICE_NAME/" | grep PHP_VERSION | grep -q "$version"
    done

    # shellcheck disable=SC2043
    for version in 7; do
      SERVICE_NAME="web_${version}_0_${server}"
      wait_for_remote_ports 60 "$SERVICE_NAME:443"
      curl --insecure --fail "https://$SERVICE_NAME/" | grep PHP_VERSION | grep -q "${version}\.0"
    done
  done
}
