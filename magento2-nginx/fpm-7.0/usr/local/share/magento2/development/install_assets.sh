#!/bin/sh

echo 'extracting media files'
tar --no-same-owner --extract --gzip --file=tools/assets/development/media.files.tgz || exit 1
