#!/usr/bin/env bash
if [[ "$INDEX_SEARCH_ENGINE" == "es" ]] ; then
    echo "ES not supported anymore. Only SOLR"
    exit 1
else
    export SOLR_ENDPOINT=$SOLR_INTERNAL_ENDPOINT
    env | fgrep SOLR
    bundle exec rake bridge:build_solr_product_search_index
fi
