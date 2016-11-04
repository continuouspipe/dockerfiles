#!/bin/bash

set -xe

echo 'extracting media files'
as_build "tar --no-same-owner --extract --gzip --file=tools/assets/development/media.files.tgz || exit 1"
