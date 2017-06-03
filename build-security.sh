#!/bin/bash

set -xe

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi

function get_before_instructions() {
  local IMAGE_NAME
  IMAGE_NAME="$1"
  if [[ "${IMAGE_NAME}" =~ solr6 ]]; then
    echo "USER root"
  fi
}

function get_after_instructions() {
  local IMAGE_NAME
  IMAGE_NAME="$1"
  if [[ "${IMAGE_NAME}" =~ solr6 ]]; then
    echo "USER solr"
  fi
}

# Get list of images
IMAGE_NAMES="$(grep "quay.io\/continuouspipe\/.*" "${DIR}/docker-compose.yml" | cut -d ":" -f2)"

# Get list of image names without the organisation
SHORT_IMAGE_NAMES="$(echo "$IMAGE_NAMES" | cut -d "/" -f3)"
# shellcheck disable=SC2086
read -r -a SHORT_IMAGE_NAMES <<<$SHORT_IMAGE_NAMES
# shellcheck disable=SC2086
read -r -a IMAGE_NAMES <<<$IMAGE_NAMES

mkdir -p "${DIR}/security/tmp/"

# Generate a dockerfile for each image
image_counter=0
for IMAGE_NAME in "${IMAGE_NAMES[@]}"; do
  sed "s/{{IMAGE_NAME}}/${IMAGE_NAME//\//\/}/g" "${DIR}/security/Dockerfile-security.tmpl" > "${DIR}/security/tmp/Dockerfile-${SHORT_IMAGE_NAMES[$image_counter]}"
  BEFORE_INSTRUCTIONS="$(get_before_instructions "${IMAGE_NAME}")"
  sed -i '' "s/{{BEFORE_INSTRUCTIONS}}/${BEFORE_INSTRUCTIONS}/" "${DIR}/security/tmp/Dockerfile-${SHORT_IMAGE_NAMES[$image_counter]}"
  AFTER_INSTRUCTIONS="$(get_after_instructions "${IMAGE_NAME}")"
  sed -i '' "s/{{AFTER_INSTRUCTIONS}}/${AFTER_INSTRUCTIONS}/" "${DIR}/security/tmp/Dockerfile-${SHORT_IMAGE_NAMES[$image_counter]}"
  ((image_counter=image_counter+1))
done

# Update docker-compose.yml to build the security tag
perl -p0e "s/(\s+)build:.+?(image:\s*quay\.io\/continuouspipe\/(.+?):)latest/\1build:\1  context: .\1  dockerfile: Dockerfile-\3\1\2security-$(date +%Y-%m-%d)/sg" "${DIR}/docker-compose.yml" > "${DIR}/security/tmp/docker-compose.yml"

echo "Building all images:"; echo
(cd "$DIR/security/tmp/" && docker-compose build --pull --force-rm)

read -r -p "Would you like to publish the images? [Y/n] " DO_PUBLISH

if [ -z "$DO_PUBLISH" ]; then
  DO_PUBLISH='y'
fi

DO_PUBLISH="$(echo $DO_PUBLISH | tr '[:upper:]' '[:lower:]')"
if [ "$DO_PUBLISH" = 'y' ]; then
  echo "Pushing our images:"; echo
  (cd "${DIR}/security/tmp/" && docker-compose push)
else
  echo "Not Pushing our images."; echo
fi

echo "Done!"; echo
