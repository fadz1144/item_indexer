#!/usr/bin/env bash

# this will add any fields that need to be added to the index; equivalent of a db:migrate for SOLR
bundle exec rake bridge:apply_solr_schema

if [[ "$INDEX_SEARCH_ENGINE" == "es" ]] ; then
    echo "ES not supported anymore. Only SOLR"
    exit 1
else
    export SOLR_ENDPOINT=$SOLR_INTERNAL_ENDPOINT
    env | fgrep SOLR
    bundle exec rake bridge:build_solr_product_search_index
fi
