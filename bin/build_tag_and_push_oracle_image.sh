#!/usr/bin/env bash

docker build -t item_indexer_oracle -f Dockerfile.oracle . &&
    docker tag item_indexer_oracle us.gcr.io/upc-dev/item_indexer_oracle &&
    docker push us.gcr.io/upc-dev/item_indexer_oracle
