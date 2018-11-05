#!/bin/bash
export SOLR_ENDPOINT="${SOLR_INTERNAL_ENDPOINT}"
ruby solr/bin/init_solr_index.rb
