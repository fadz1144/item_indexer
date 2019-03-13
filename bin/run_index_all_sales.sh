#!/usr/bin/env bash

# set up environment
export SOLR_ENDPOINT=$SOLR_INTERNAL_ENDPOINT
env | fgrep SOLR

# ping solr and capture exit status...
echo "pinging Solr..."
bundle exec rake bridge:ping_solr
return_code=$?

# ...abort task if failed
if [[ $return_code -ne 0 ]]; then
        echo "pinging Solr...FAILED"
        exit $return_code
else
        echo "pinging Solr...OK"
fi

# this will add any fields that need to be added to the index; equivalent of a db:migrate for SOLR
echo "applying sales schema..."
bundle exec rake bridge:apply_solr_sales_schema
echo "applying sales schema...done"

echo "adding sales data to index..."
bundle exec rake bridge:build_solr_sales_search_index
echo "adding sales data to index...done"
