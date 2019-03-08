#!/bin/bash

# this will add any fields that need to be added to the index; equivalent of a db:migrate for SOLR
bundle exec rake bridge:apply_solr_schema