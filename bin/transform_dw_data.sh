#!/bin/bash

# this will add inbound data from inbound 'contribution margin feed' to 'concept_sku_pricing'
bundle exec rake bridge:run_transformation_job[DW]

# this will add inbound data from inbound 'dw sales metrics feed' to 'concept_sku_pricing'
bundle exec rake bridge:run_transformation_job[SALES]