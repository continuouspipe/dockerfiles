#!/bin/bash

set -e

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi

docker pull koalaman/shellcheck:v0.4.6
docker pull lukasmartinelli/hadolint

find "$DIR" -type f ! -path "*.git/*" ! -name "*.py" \( \
  -perm +111 -or -name "*.sh" -or -wholename "*usr/local/share/env/*" -or -wholename "*usr/local/share/container/*" \
\) | while read -r script; do
  echo "Linting '$script':";
  docker run --rm -i koalaman/shellcheck:v0.4.6 --exclude SC1091 - < "$script";
  echo
done

find "$DIR" -type f -name "Dockerfile*" ! -name "*.tmpl" | while read -r dockerfile; do
  echo "Linting '$dockerfile':";
  docker run --rm -i lukasmartinelli/hadolint hadolint --ignore DL3008 --ignore DL3002 --ignore DL4001 --ignore DL3007 --ignore SC2016 - < "$dockerfile"
  echo
done

docker-compose run --rm tests
