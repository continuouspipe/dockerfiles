#!/bin/bash

set -xe

SOLR_CORE_NAME=${SOLR_CORE_NAME:-maincore}

mkdir -p "/usr/local/share/solr/$SOLR_CORE_NAME/data/tlog" \
 && chown -R solr:solr "/usr/local/share/solr/$SOLR_CORE_NAME/data/" \
 && chown solr:solr "/usr/local/share/solr/$SOLR_CORE_NAME/"

exec su -l solr -c "exec /opt/solr/bin/solr -f -s /usr/local/share/solr/ | tee /tmp/solr.log" &

check_for_solr_started()
{
  grep -q "Started SocketConnector@0.0.0.0:8983" /tmp/solr.log
}

set +e
check_for_solr_started
while [ "$?" -ne 0 ]; do
  sleep 1
  check_for_solr_started
done

# Clean up
pkill -9 tee
rm /tmp/solr.log

# Check for existing core
curl -s "http://localhost:8983/solr/admin/cores?action=STATUS&core=$SOLR_CORE_NAME" | grep -q "<str name=\"name\">$SOLR_CORE_NAME</str>"
CORE_EXISTS=$?
set -e
if [ "$CORE_EXISTS" -ne 0 ]; then
  curl -IX GET "http://localhost:8983/solr/admin/cores?action=CREATE&name=d8&instanceDir=$SOLR_CORE_NAME&config=solrconfig.xml&schema=schema.xml&dataDir=data"
fi
