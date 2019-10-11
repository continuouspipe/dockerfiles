#!/bin/bash

set -e

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")"
else
    DIR="$(dirname "$0")"
fi

export PARALLEL_SHELL="./ubuntu/16.04/usr/local/share/bootstrap/parallel_shell_wrapper.sh"

templated_files()
{
  shopt -s nullglob
  set -- "${DIR}"/*/build.sh
  if [ "$#" -gt 0 ]; then
    for file in "$@"; do
      # shellcheck source=/dev/null
      source "${file}"
    done
  fi
}

pull_images()
{
  # external_* services are used to fetch only upstream base images.
  # build --pull would otherwise overwrite the newly built dependency of a service with the old repo version
  echo "Pulling any external images:"; echo
  (cd "$DIR" && docker-compose config --services | grep external | xargs docker-compose "${DOCKER_COMPOSE_FILES[@]}" pull --quiet)
}

build_images()
{
  DOCKER_BUILD_FLAGS=(--force-rm)
  if [ "$PARALLEL" != "false" ]; then
    DOCKER_BUILD_FLAGS+=(--parallel)
  fi
  echo "Building images:"; echo
  (cd "$DIR" && docker-compose "${DOCKER_COMPOSE_FILES[@]}" build "${DOCKER_BUILD_FLAGS[@]}" "${DOCKER_IMAGES[@]}")
}
export -f build_images

publish_images()
{
  if [ -z "$DO_PUBLISH" ]; then
    read -r -p "Would you like to publish the images? [Y/n] " DO_PUBLISH
  fi

  if [ -z "$DO_PUBLISH" ]; then
    DO_PUBLISH='n'
  fi

  DO_PUBLISH="$(echo "$DO_PUBLISH" | tr '[:upper:]' '[:lower:]')"
  if [ "$DO_PUBLISH" = 'y' ]; then
    echo "Pushing our images:"; echo
    parallel --halt-on-error now,fail=1 --no-notice --line-buffer --tag --tagstring "Pushing {}:" docker-compose "${DOCKER_COMPOSE_FILES[@]}" push ::: "${DOCKER_IMAGES[@]}"
  else
    echo "Not Pushing our images."; echo
  fi
}
export -f publish_images

eol_variables()
{
  DOCKER_COMPOSE_FILES=(-f docker-compose.yml -f docker-compose.eol.yml)
  DOCKER_IMAGES=(
    'ubuntu'
    'php55_nginx'
    'magento1_php55_nginx'
  )
  export DOCKER_COMPOSE_FILES
  export DOCKER_IMAGES
  export PARALLEL="false"
}

variables()
{
  local LEVEL="$1"
  DOCKER_COMPOSE_FILES=(-f docker-compose.yml)
  DOCKER_IMAGES=()
  if [ "${LEVEL}" -eq 3 ]; then
    DOCKER_IMAGES+=(
      'ubuntu'
    )
  elif [ "${LEVEL}" -eq 2 ]; then
    DOCKER_IMAGES+=(
      'nginx'
      'php73_apache'
      'php72_apache'
      'php71_apache'
      'php70_apache'
      'php56_apache'
      'php73_nginx'
      'php72_nginx'
      'php71_nginx'
      'php70_nginx'
      'php56_nginx'
      'solr_4_10'
      'solr_6_2'
      'varnish'
    )
  elif [ "${LEVEL}" -eq 1 ]; then
    DOCKER_IMAGES+=(
      'symfony_php72_nginx'
      'symfony_php71_nginx'
      'symfony_php72_apache'
      'symfony_php71_apache'
      'symfony_php70_apache'
    )
  elif [ "${LEVEL}" -eq 0 ]; then
    DOCKER_IMAGES+=(
      'couchdb16'
      'drupal_php71_apache'
      'drupal_php70_apache'
      'drupal8_apache_php7'
      'drupal_php56_apache'
      'drupal8_solr_4_10'
      'drupal8_solr_6_2'
      'drupal8_varnish'
      'elasticsearch17'
      'elasticsearch24'
      'elasticsearch55'
      'elasticsearch56'
      'ezplatform_php70_apache'
      'ezplatform_php71_apache'
      'hem'
      'magento1_php56_apache'
      'magento1_php56_nginx'
      'magento2_php70_nginx'
      'magento2_php70_nginx_ng'
      'magento2_php71_nginx'
      'magento2_php71_nginx_ng'
      'magento2_php72_nginx_ng'
      'magento2_php73_nginx_ng'
      'magento2_varnish'
      'mailcatcher'
      'memcached'
      'mongodb34'
      'mongodb36'
      'mysql80'
      'mysql57'
      'mysql56'
      'mysql55'
      'nginx_ingress_controller'
      'nginx_reverse_proxy'
      'nodejs6'
      'nodejs6_small'
      'nodejs7'
      'nodejs7_small'
      'nodejs8'
      'nodejs8_small'
      'phantomjs2'
      'piwik_php71_apache'
      'postgres94'
      'postgres96'
      'rabbitmq36_management'
      'rabbitmq37_management'
      'redis'
      'scala_sbt'
      'ssh_forward'
      'spryker_php71_nginx'
      'spryker_php71_apache'
      'spryker_php72_nginx'
      'spryker_php72_apache'
      'spryker_php73_nginx'
      'spryker_php73_apache'
      'symfony_php70_nginx'
      'symfony_php56_nginx'
      'symfony_php56_apache'
      'symfony_pack'
      'tideways'
    )
  fi
  export DOCKER_COMPOSE_FILES
  export DOCKER_IMAGES
}
export -f variables

run_build()
(
  set -e
  local level="$1"
  time {
    variables "$level"
    build_images
  }
)
export -f run_build

run_publish()
(
  set -e
  local level="$1"
  if [ "$level" -gt 3 ]; then
    return 0;
  fi
  time {
    variables "$level"
    publish_images
  }
)
export -f run_publish

main()
{
  EOL_BUILD="${EOL_BUILD:-false}"
  templated_files
  time {
    pull_images
  }
  if [ "${EOL_BUILD}" == 'true' ]; then
    eol_variables
    time {
      build_images
    }
    time {
      publish_images
    }
  else
    for level in 3 2 1 0; do
      echo "travis_fold:start:build_level_$level"
      parallel --halt-on-error now,fail=1 --no-notice --line-buffer --tag --link ::: run_build run_publish ::: "$level" "$((level + 1))"
      echo "travis_fold:end:build_level_$level"
    done

    echo "travis_fold:start:push_level_0"
    run_publish 0
    echo "travis_fold:end:push_level_0"
  fi
  echo "Done!"
}

main
