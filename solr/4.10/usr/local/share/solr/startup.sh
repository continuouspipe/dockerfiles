#!/bin/bash

# Force bash job control on, to allow us to make solr be in the foreground later
set -m

set -xe

SOLR_CORE_NAME=${SOLR_CORE_NAME:-maincore}

mkdir -p "/usr/local/share/solr/$SOLR_CORE_NAME/data/tlog" \
 && chown -R solr:solr "/usr/local/share/solr/$SOLR_CORE_NAME/data/" \
 && chown solr:solr "/usr/local/share/solr/$SOLR_CORE_NAME/"

# Run solr in the background, siphoning logs to /tmp/solr.log temporarily until booted.
exec su -l solr -c "exec /opt/solr/bin/solr -f -s /usr/local/share/solr/ | tee /tmp/solr.log" &

check_for_solr_started()
{
  grep -q "Started SocketConnector@0.0.0.0:8983" /tmp/solr.log
}

set +e
until check_for_solr_started; do
  sleep 1
done

# Clean up
pkill -9 tee
rm /tmp/solr.log

# Check for existing core
curl -s "http://localhost:8983/solr/admin/cores?action=STATUS&core=$SOLR_CORE_NAME" | grep -q "<str name=\"name\">$SOLR_CORE_NAME</str>"
CORE_EXISTS=$?
if [ "$CORE_EXISTS" -ne 0 ]; then
  curl -IX GET "http://localhost:8983/solr/admin/cores?action=CREATE&name=d8&instanceDir=$SOLR_CORE_NAME&config=solrconfig.xml&schema=schema.xml&dataDir=data"
fi

# Let solr force this bash process to continue, avoiding docker daemon thinking we have crashed.
fg
