#!/usr/bin/env bash

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
echo "applying schema..."
bundle exec rake bridge:apply_solr_schema
echo "applying schema...OK"

echo "adding products to index..."
export SOLR_ENDPOINT=$SOLR_INTERNAL_ENDPOINT
env | fgrep SOLR
bundle exec rake bridge:build_solr_product_search_index
echo "adding products to index...OK"
