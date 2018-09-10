#!/bin/bash

gsutil --version || ( echo "Sorry, you need gsutil to run the secrets-entrypoint. Try installing the Google Cloud SDK." ; exit 2 )

# Check that the environment variable has been set correctly
if [ -z "$SECRETS_BUCKET_NAME" ]; then
  echo >&2 "Using bucket: upc-dev-secrets (the default)"
else
  echo >&2 "Using bucket: ${SECRETS_BUCKET_NAME}"
fi

SECRETS_BUCKET_NAME="${SECRETS_BUCKET_NAME:-upc-dev-secrets}"

eval $(gsutil cp gs://${SECRETS_BUCKET_NAME}/base.txt - | sed 's/^/export /')

if [ -z "$ENVIRONMENT_TOKEN" ]; then
  echo >&2 'warning: missing ENVIRONMENT_TOKEN environment variable.  only using `base` values'
else
  # Override the base with the environment specific variables
  eval $(gsutil cp gs://${SECRETS_BUCKET_NAME}/${ENVIRONMENT_TOKEN}.txt - | sed 's/^/export /')
fi

if [[ -n "${CLOUD_SQL_PROXY_INSTANCE}" ]] ; then
    bin/install_and_start_cloud_sql_proxy.sh "${CLOUD_SQL_PROXY_INSTANCE}"
    source dbhost.sh
    env | grep DATABASE_HOST
fi

exec "$@"
