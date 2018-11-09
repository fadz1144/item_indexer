#!/bin/bash
export SOLR_ENDPOINT="${SOLR_INTERNAL_ENDPOINT}"
ruby solr/bin/apply_solr_schema.rb
