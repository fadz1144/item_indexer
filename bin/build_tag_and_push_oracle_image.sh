#!/usr/bin/env bash

set -e

REPO="us.gcr.io/upc-dev"
IMAGE_NAME="item_indexer_oracle"
# Set DEFAULT_TAG to what we normally use for 'production'
DEFAULT_TAG="V1"

VTAG="${1:-$DEFAULT_TAG}"
echo "Using tag: $VTAG"

docker build --tag ${IMAGE_NAME}:${VTAG} -f Dockerfile.oracle .
docker tag ${IMAGE_NAME}:${VTAG} ${REPO}/${IMAGE_NAME}:${VTAG}
docker push ${REPO}/${IMAGE_NAME}:${VTAG}

if [[ "$VTAG" = "$DEFAULT_TAG" ]] ; then
    echo "Also pushing 'latest' because you are using the default tag (${VTAG})."
    LT=latest
    docker tag ${IMAGE_NAME}:${VTAG} ${REPO}/${IMAGE_NAME}:${LT}
    docker push ${REPO}/${IMAGE_NAME}:${LT}
fi
