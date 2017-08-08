#!/bin/bash

if [ -n "$IS_INNER_REQUEST" ]; then
  return 0
fi
SOLR_CORE_NAME=${SOLR_CORE_NAME:-maincore}
IS_INNER_REQUEST="true" /opt/docker-solr/scripts/docker-entrypoint.sh solr-create -c "${SOLR_CORE_NAME}" -d /usr/local/share/solr/
