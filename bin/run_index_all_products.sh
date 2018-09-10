#!/usr/bin/env bash
if [[ "$INDEX_SEARCH_ENGINE" == "solr" ]] ; then
    export SOLR_ENDPOINT=$SOLR_INTERNAL_ENDPOINT
    env | fgrep SOLR
    bundle exec rake bridge:build_solr_product_search_index
else
    bundle exec rake bridge:build_product_search_index
fi
