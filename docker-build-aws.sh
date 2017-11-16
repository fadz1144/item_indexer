#!/usr/bin/env bash
docker build -t item_indexer_aws -f ${OKL_DEV_ROOT}/item_indexer/Dockerfile.aws --build-arg ssh_prv_key="$(cat ~/.ssh/bbb-labs-automation)"  ${OKL_DEV_ROOT}/item_indexer/.
