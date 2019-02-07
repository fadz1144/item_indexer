#!/usr/bin/env bash

docker build -t item-indexer-sftp -f Dockerfile.sftp . &&
    docker tag item-indexer-sftp us.gcr.io/upc-dev/item-indexer-sftp:latest &&
    docker push us.gcr.io/upc-dev/item-indexer-sftp:latest
