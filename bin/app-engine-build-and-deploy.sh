#!/bin/bash

PROJECT=$( gcloud config get-value project | xargs )
SERVICE=$1

if [[ "$SERVICE" = "" ]]  ; then
    SERVICE=$(basename $(pwd) | sed -e 's/[^a-z0-9A-Z]/-/g')
    echo "Warning: Service not provided as a parameter, guessing '$SERVICE' based on pwd."
fi

# Give up if anything exits abnormally
set -e

GAE_VERSION_TAG=$(date -u '+%Y%m%dt%H%M%S')

IMAGE="us.gcr.io/${PROJECT}/appengine/${SERVICE}.${GAE_VERSION_TAG}"

docker build -t "${SERVICE}:latest" .
docker tag "${SERVICE}:latest" "${IMAGE}"
docker push "${IMAGE}"

gcloud app deploy -q ./app.yaml --image-url="${IMAGE}" --version="${GAE_VERSION_TAG}" --stop-previous-version
