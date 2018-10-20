#!/bin/bash

set -e

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")"
else
    DIR="$(dirname "$0")"
fi

docker pull koalaman/shellcheck:v0.4.6
docker pull lukasmartinelli/hadolint

run_shellcheck()
{
  local script="$1"
  docker run --rm -i koalaman/shellcheck:v0.4.6 --exclude SC1091 - < "$script" && echo "OK"
}
export -f run_shellcheck

find "$DIR" -type f ! -path "*.git/*" ! -name "*.py" \( \
  -perm +111 -or -name "*.sh" -or -wholename "*usr/local/share/env/*" -or -wholename "*usr/local/share/container/*" \
\) | parallel --no-notice --line-buffer --tag --tagstring "Linting {}:" run_shellcheck

run_hadolint()
{
  local dockerfile="$1"
  docker run --rm -i lukasmartinelli/hadolint hadolint --ignore DL3008 --ignore DL3002 --ignore DL3003 --ignore DL4001 --ignore DL3007 --ignore SC2016 - < "$dockerfile" && echo "OK"
}
export -f run_hadolint

find "$DIR" -type f -name "Dockerfile*" ! -name "*.tmpl" | parallel --no-notice --line-buffer --tag --tagstring "Linting {}:" run_hadolint

# Run unit tests
docker-compose -f docker-compose.yml -f docker-compose.test.yml build ubuntu
docker-compose -f docker-compose.yml -f docker-compose.test.yml run --rm tests

run_integration_tests()
{
  local integration_docker_compose="$1"
  echo "Running integration tests for '$integration_docker_compose':"
  docker-compose -f docker-compose.yml -f "$integration_docker_compose" build --parallel integration_tests
  docker-compose -f docker-compose.yml -f "$integration_docker_compose" up --exit-code-from integration_tests integration_tests
  docker-compose -f docker-compose.yml -f "$integration_docker_compose" down -v
}
export -f run_integration_tests

# Run integration tests
find "$DIR" -type f -path "*/tests/integration/docker-compose.yml" | parallel --no-notice --line-buffer --tag --tagstring "Integration {}:" run_integration_tests
