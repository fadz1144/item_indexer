#!/usr/bin/env bash
aws ecr get-login --no-include-email | sh
docker build -t item_indexer_aws -f ${OKL_DEV_ROOT}/item_indexer/Dockerfile.aws --build-arg ssh_prv_key="$(cat ~/.ssh/bbb-labs-automation)" ${OKL_DEV_ROOT}/item_indexer/.
docker tag item_indexer_aws 774076615373.dkr.ecr.us-east-1.amazonaws.com/bbb-labs/item_indexer:latest
docker push 774076615373.dkr.ecr.us-east-1.amazonaws.com/bbb-labs/item_indexer:latest
