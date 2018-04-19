#!/bin/bash

set -e

main() {
  SERVICES=""
  SERVICES="$(get_services | sed 's/_stable$//')"

  docker build tools/compare/ -t dockerfilescompare_compare:latest

  for service in $SERVICES; do
    echo "$service:"
    prepare "$service"
    compare "$service"
    tag "$service"
    cleanup "$service"
    echo
  done
}

prepare()
{
  local SERVICE="$1"
  prepare_latest "$service"
  prepare_stable "$service"
}

prepare_latest()
{
  local SERVICE="$1"
  pull_latest "$service"
  create_container_latest "$service"
  export_latest "$service"
}

prepare_stable()
{
  local SERVICE="$1"
  pull_stable "$service"
  create_container_stable "$service"
  export_stable "$service"
}

docker_compose_latest()
{
  docker-compose -p dockerfiles_compare -f docker-compose.yml "$@"
}

docker_compose_stable()
{
  docker-compose -p dockerfiles_compare -f docker-compose.stable.yml "$@"
}

get_services()
{
  docker_compose_stable config --services
}

pull_latest()
{
  local SERVICE="$1"
  docker_compose_latest pull "$SERVICE"
}

pull_stable()
{
  local SERVICE="$1"
  docker_compose_stable pull "${SERVICE}_stable"
}

create_container_latest()
{
  local SERVICE="$1"
  docker_compose_latest run --no-deps "$SERVICE" /bin/true
}

create_container_stable()
{
  local SERVICE="$1"
  docker_compose_stable run --no-deps "${SERVICE}_stable" /bin/true
}

remove_containers_latest()
{
  docker_compose_latest down -v
}

remove_containers_stable()
{
  docker_compose_stable down -v
}

export_latest()
{
  local SERVICE="$1"
  mkdir -p tmp
  docker export "dockerfilescompare_${SERVICE}_run_1" -o "tmp/${SERVICE}_latest.tar"
}

export_stable()
{
  local SERVICE="$1"
  mkdir -p tmp
  docker export "dockerfilescompare_${SERVICE}_stable_run_1" -o "tmp/${SERVICE}_stable.tar"
}

compare()
{
  local SERVICE="$1"
  docker run --rm -v "$(pwd)/tmp:/tmp/archives" dockerfilescompare_compare bash /app/compare.sh "$SERVICE" | less
}

tag()
{
  local SERVICE="$1"
  if ask_for_tag "$SERVICE"; then
    do_tag "$SERVICE"
    push "$SERVICE"
  fi
}

ask_for_tag()
(
  set +e
  local SERVICE="$1"
  echo "Do you wish to tag $SERVICE as :stable?"
  select yn in "Yes" "No"; do
    case $yn in
      Yes ) return 0; break;;
      No ) return 1; break;;
    esac
  done
  return 1
)

do_tag()
{
  local SERVICE="$1"
  local IMAGE=""
  IMAGE="$(docker_compose_stable config | grep -A1 "$SERVICE" | grep image: | cut -d":" -f2 | tr -d ' ')"
  if [ -z "$IMAGE" ]; then
    return 1
  fi
  docker tag "${IMAGE}:latest" "${IMAGE}:stable"
}

push()
{
  local SERVICE="$1"
  if ask_for_push "$SERVICE"; then
    do_push "$SERVICE"
  fi
}

ask_for_push()
(
  set +e
  local SERVICE="$1"
  echo "Do you wish to push :stable for $SERVICE now?"
  select yn in "Yes" "No"; do
    case $yn in
      Yes ) return 0; break;;
      No ) return 1; break;;
    esac
  done
  return 1
)

do_push()
{
  set -x
  local SERVICE="$1"
  if [ -z "$SERVICE" ]; then
    return 1
  fi
  docker_compose_stable push "${SERVICE}_stable"
}

cleanup()
{
  local SERVICE="$1"
  cleanup_latest "$SERVICE"
  cleanup_stable "$SERVICE"
}

cleanup_latest()
{
  local SERVICE="$1"
  remove_containers_latest
  rm "tmp/${SERVICE}_latest.tar"
}

cleanup_stable()
{
  local SERVICE="$1"
  remove_containers_stable
  rm "tmp/${SERVICE}_stable.tar"
}

main
