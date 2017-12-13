#!/bin/bash

function sentinel_command()
{
  redis-cli -h redis-sentinel -p 26379 --csv SENTINEL "$@"
}

function get_existing_master()
{
  sentinel_command get-master-addr-by-name mymaster | tr ',' ' ' | cut -d' ' -f1 | cut -d'"' -f2
}

function sentinel_info()
{
  # Print out the info of other sentinels
  sentinel_command sentinels mymaster
}

function master_failover()
{
  echo "> Triggering a failover from $(get_existing_master)"
  sentinel_command failover mymaster
  echo "> Failover triggered"
}

function wait_for_exit()
{
  local WAIT_FOR="$1"
  echo "> Waiting for $WAIT_FOR to stop accepting connections"
  wait_for_remote_ports_to_close 120 "$WAIT_FOR"
  echo "> $WAIT_FOR has stopped accepting connections"
}

function sentinel_cleanup()
{
  local EXISTING_MASTER="$1"
  # Run reset on each sentinel, including the current "redis-sentinel" pod.
  # "SENTINEL sentinels mymaster" returns knowledge of the *other* sentinel pods, not the one we are talking to.
  echo "> Resetting sentinel data for the container that responds as the redis-sentinel service"
  SENTINELS="$(echo -e "SENTINEL sentinels mymaster\nSENTINEL RESET mymaster\n" | redis-cli -h redis-sentinel -p 26379 --csv | sed 's/"name"/\n"name"/g' | grep "name" | grep -v 's-down-time' | sed -E 's/.*"ip","([^"]+)".*/\1/')"
  if [ -n "$EXISTING_MASTER" ]; then
    SENTINELS="$(echo "$SENTINELS" | grep -v "$EXISTING_MASTER")"
  fi
  for sentinel in $SENTINELS; do
    # Running reset on a sentinel causes it to lose track of any other sentinels and any followers of the current
    # master.
    # Sentinels are guaranteed to find out about this information from the other sentinels announcing themselves within
    # 10 seconds. To allow a little leeway, sleep for 11 seconds before resetting the next sentinel.
    echo "> Waiting for the sentinel to receive data from the other sentinels"
    sleep 11s
    echo "> Resetting sentinel data for $sentinel"
    redis-cli -h "$sentinel" -p 26379 SENTINEL RESET mymaster
  done
}

function wait_for_remote_ports_to_close() (
  set +x

  local -r TIMEOUT=$1
  local -r INTERVAL=0.5
  local -r CHECK_TOTAL=$((TIMEOUT*2))
  local COUNT
  shift

  COUNT=0
  while (test_remote_ports "$@")
  do
    ((COUNT++)) || true
    if [ "${COUNT}" -gt "${CHECK_TOTAL}" ]
    then
      echo "One of the services [$*] didn't shut down in time"
      exit 1
    fi
    sleep "${INTERVAL}"
  done
)

function test_remote_ports() {
  local SERVICE
  local SERVICE_PARAMS

  for SERVICE in "$@"; do
    IFS=':'
    # shellcheck disable=SC2206
    SERVICE_PARAMS=($SERVICE)
    unset IFS

    timeout 1 bash -c "cat < /dev/null > /dev/tcp/${SERVICE_PARAMS[0]}/${SERVICE_PARAMS[1]}" 2>/dev/null || return 1
  done
}

function master_failover_and_sentinel_cleanup()
{
  local EXISTING_MASTER
  EXISTING_MASTER="$(get_existing_master)"
  master_failover
  wait_for_exit "$EXISTING_MASTER:26379"
  sentinel_cleanup "$EXISTING_MASTER"
}

function run_master_and_sentinel()
{
  echo "> Starting initial master redis server and sentinel server"
  MASTER=true /run.sh &
  SENTINEL=true /run.sh &
  wait
}
