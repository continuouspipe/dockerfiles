#!/bin/bash

set -e

main() {
  SERVICES="$*"
  if [ -z "$SERVICES" ]; then
    SERVICES="$(get_services | sed 's/_stable$//')"
  fi

  echo "Building comparison tool image..."
  docker build tools/compare/ -t dockerfilescompare_compare:latest > /dev/null 2>&1

  for service in $SERVICES; do
    echo
    echo "__${service}__:"
    cleanup "$service"
    prepare "$service"
    if quick_compare "$service"; then
      echo "$service's stable image is identical to the latest image!"
      continue
    fi
    do_export "$service"
    compare "$service"
    tag "$service"
    cleanup "$service"
    echo
  done
}

prepare()
{
  local SERVICE="$1"
  prepare_latest "$SERVICE"
  prepare_stable "$SERVICE"
}

prepare_latest()
{
  local SERVICE="$1"
  pull_latest "$SERVICE"
}

prepare_stable()
{
  local SERVICE="$1"
  pull_stable "$SERVICE"
}

quick_compare()
{
  local SERVICE="$1"
  local IMAGE=""
  local LATEST_SHA=""
  local STABLE_SHA=""
  IMAGE="$(get_image_name "$SERVICE")"
  LATEST_SHA="$(docker inspect "${IMAGE}:latest" | grep Id | awk '{ print $2; }' | tr -d ',' | tr -d '"')"
  STABLE_SHA="$(docker inspect "${IMAGE}:stable" | grep Id | awk '{ print $2; }' | tr -d ',' | tr -d '"')"
  if [[ "$LATEST_SHA" == "$STABLE_SHA" ]]; then
    return 0
  fi
  return 1
}

do_export()
{
  local SERVICE="$1"
  do_export_latest "$SERVICE"
  do_export_stable "$SERVICE"
}

do_export_latest()
{
  local SERVICE="$1"
  create_container_latest "$SERVICE"
  export_latest "$SERVICE"
}

do_export_stable()
{
  local SERVICE="$1"
  create_container_stable "$SERVICE"
  export_stable "$SERVICE"
}

docker_compose_latest()
{
  docker-compose -p dockerfilescompare -f docker-compose.yml "$@"
}

docker_compose_stable()
{
  docker-compose -p dockerfilescompare -f docker-compose.stable.yml "$@"
}

get_services()
{
  docker_compose_stable config --services
}

pull_latest()
{
  local SERVICE="$1"
  echo "Pulling latest $SERVICE image..."
  docker_compose_latest pull "$SERVICE" > /dev/null 2>&1
}

pull_stable()
{
  local SERVICE="$1"
  echo "Pulling stable $SERVICE image..."
  docker_compose_stable pull "${SERVICE}_stable" > /dev/null 2>&1
}

get_image_name()
{
  local SERVICE="$1"
  docker_compose_stable config | grep -v " build:" | grep -v " context:" | grep -A1 "\s${SERVICE}_stable:" | grep image: | cut -d":" -f2 | tr -d ' '
}

create_container_latest()
{
  local SERVICE="$1"
  echo "Creating container from latest $SERVICE image..."
  docker_compose_latest run --no-deps "$SERVICE" /bin/true
}

create_container_stable()
{
  local SERVICE="$1"
  echo "Creating container from stable $SERVICE image..."
  docker_compose_stable run --no-deps "${SERVICE}_stable" /bin/true
}

remove_latest_containers()
{
  echo "Removing any existing comparison containers"
  docker_compose_latest down -v > /dev/null 2>&1
}

remove_stable_containers()
{
  echo "Removing any existing comparison containers"
  docker_compose_stable down -v > /dev/null 2>&1
}

export_latest()
{
  local SERVICE="$1"
  mkdir -p tmp
  echo "Exporting dockerfilescompare_${SERVICE}_run_1 to tmp/${SERVICE}_latest.tar"
  docker export "dockerfilescompare_${SERVICE}_run_1" -o "tmp/${SERVICE}_latest.tar"
}

export_stable()
{
  local SERVICE="$1"
  mkdir -p tmp
  echo "Exporting dockerfilescompare_${SERVICE}_stable_run_1 to tmp/${SERVICE}_stable.tar"
  docker export "dockerfilescompare_${SERVICE}_stable_run_1" -o "tmp/${SERVICE}_stable.tar"
}

compare()
(
  local SERVICE="$1"
  echo "Comparing tmp/${SERVICE}_stable.tar to tmp/${SERVICE}_latest.tar..."
  local DIFF
  set +e
  DIFF="$(docker run --rm -v "$(pwd)/tmp:/tmp/archives" dockerfilescompare_compare bash /app/compare.sh "$SERVICE")"
  local DIFF_EXIT="$?"
  if [ "$DIFF_EXIT" -eq 0 ]; then
    echo "No differences found!"
    return 0
  else
    set -e
    echo "$DIFF" | less
  fi
)

tag()
{
  local SERVICE="$1"
  if ask_for_tag "$SERVICE"; then
    TAG_NAME="$(get_old_tag_name)"
    do_tag "$SERVICE" "$TAG_NAME"
    push "$SERVICE" "$TAG_NAME"
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

get_old_tag_name()
{
  echo "old-stable-$(date -u +"%Y%m%d-%H%M")"
}

do_tag()
{
  local SERVICE="$1"
  local OLD_TAG_NAME="$2"
  local IMAGE
  IMAGE="$(get_image_name "$SERVICE")"
  if [ -z "$IMAGE" ]; then
    return 1
  fi

  echo "Tagging current ${IMAGE}:stable as ${IMAGE}:${OLD_TAG_NAME}"
  docker tag "${IMAGE}:stable" "${IMAGE}:${OLD_TAG_NAME}"
  echo "Tagging ${IMAGE}:latest as ${IMAGE}:stable"
  docker tag "${IMAGE}:latest" "${IMAGE}:stable"
}

push()
{
  local SERVICE="$1"
  local OLD_TAG_NAME="$2"
  if ask_for_push "$SERVICE"; then
    do_push "$SERVICE" "$OLD_TAG_NAME"
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
  local SERVICE="$1"
  local OLD_TAG_NAME="$2"
  local IMAGE=""
  if [ -z "$SERVICE" ]; then
    return 1
  fi
  IMAGE="$(get_image_name "$SERVICE")"

  echo "Pushing ${IMAGE}:${OLD_TAG_NAME}..."
  docker push "${IMAGE}:${OLD_TAG_NAME}" > /dev/null 2>&1

  echo "Pushing ${IMAGE}:stable..."
  docker push "${IMAGE}:stable" > /dev/null 2>&1
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
  remove_latest_containers
  if [ -f "tmp/${SERVICE}_latest.tar" ]; then
    rm "tmp/${SERVICE}_latest.tar"
  fi
}

cleanup_stable()
{
  local SERVICE="$1"
  remove_stable_containers
  if [ -f "tmp/${SERVICE}_stable.tar" ]; then
    rm "tmp/${SERVICE}_stable.tar"
  fi
}

main "$@"
