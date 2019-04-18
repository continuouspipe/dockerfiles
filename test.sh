#!/bin/bash

set -e

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")"
else
    DIR="$(dirname "$0")"
fi

export PARALLEL_SHELL="./ubuntu/16.04/usr/local/share/bootstrap/parallel_shell_wrapper.sh"

echo "travis_fold:start:pull_test_images"
time docker pull koalaman/shellcheck:v0.4.6
time docker pull lukasmartinelli/hadolint:latest
echo "travis_fold:end:pull_test_images"

run_shellcheck()
{
  set -e
  local script="$1"
  docker run --rm -i koalaman/shellcheck:v0.4.6 --exclude SC1091 - < "$script" && echo "OK"
}
export -f run_shellcheck

echo "travis_fold:start:lint_scripts"
time {
  find "$DIR" -type f ! -path "*.git/*" ! -name "*.py" \( \
    -perm +111 -or -name "*.sh" -or -wholename "*usr/local/share/env/*" -or -wholename "*usr/local/share/container/*" \
  \) | parallel --halt-on-error now,fail=1 --no-notice --line-buffer --tag --tagstring "Linting {}:" run_shellcheck
}
echo "travis_fold:end:lint_scripts"

run_hadolint()
{
  set -e
  local dockerfile="$1"
  docker run --rm -i lukasmartinelli/hadolint:latest hadolint --ignore DL3008 --ignore DL3002 --ignore DL3003 --ignore DL4001 --ignore DL3007 --ignore SC2016 --ignore SC2028 - < "$dockerfile" && echo "OK"
}
export -f run_hadolint

echo "travis_fold:start:lint_dockerfiles"
time {
  find "$DIR" -type f -name "Dockerfile*" ! -name "*.tmpl" | parallel --halt-on-error now,fail=1 --no-notice --line-buffer --tag --tagstring "Linting {}:" run_hadolint
}
echo "travis_fold:end:lint_dockerfiles"

# Run unit tests
echo "travis_fold:start:build_ubuntu_image"
time docker-compose -f docker-compose.yml -f docker-compose.test.yml build --pull ubuntu
echo "travis_fold:end:build_ubuntu_image"
echo "travis_fold:start:unit_tests"
time docker-compose -f docker-compose.yml -f docker-compose.test.yml run --rm tests
echo "travis_fold:end:unit_tests"

run_integration_tests()
{
  set -e
  local integration_docker_compose="$1"
  echo "Running integration tests for '$integration_docker_compose':"
  time docker-compose -f docker-compose.yml -f "$integration_docker_compose" build --parallel integration_tests
  time docker-compose -f docker-compose.yml -f "$integration_docker_compose" up --exit-code-from integration_tests integration_tests
  time docker-compose -f docker-compose.yml -f "$integration_docker_compose" down -v
}
export -f run_integration_tests

echo "travis_fold:start:integration_tests"
# Run integration tests
time {
  find "$DIR" -type f -path "*/tests/integration/docker-compose.yml" | parallel --halt-on-error now,fail=1 --no-notice --line-buffer --tag --tagstring "Integration {}:" run_integration_tests
}
echo "travis_fold:end:integration_tests"
