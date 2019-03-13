#!/bin/bash
export SOLR_ENDPOINT="${SOLR_INTERNAL_ENDPOINT}"
export SOLR_CORE="sales"
ruby solr/bin/apply_solr_schema.rb
