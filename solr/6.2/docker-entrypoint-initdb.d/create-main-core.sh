#!/bin/bash

SOLR_CORE_NAME=${SOLR_CORE_NAME:-maincore}
/opt/docker-solr/scripts/docker-entrypoint.sh solr-create -c "${SOLR_CORE_NAME}" -d /usr/local/share/solr/
