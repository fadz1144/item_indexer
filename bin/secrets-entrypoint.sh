#!/bin/bash

# Check that the environment variable has been set correctly
if [ -z "$SECRETS_BUCKET_NAME" ]; then
  echo >&2 'error: missing SECRETS_BUCKET_NAME environment variable'
  exit 1
fi

# Load the base S3 secrets file contents into the environment variables
eval $(aws s3 cp s3://${SECRETS_BUCKET_NAME}/base.env - | sed 's/^/export /')

# Check that the environment variable has been set correctly
if [ -z "$ENVIRONMENT_TOKEN" ]; then
  echo >&2 'warning: missing ENVIRONMENT_TOKEN environment variable.  only using BASE values'
else
  # Override the base with the environment specific variables
  eval $(aws s3 cp s3://${SECRETS_BUCKET_NAME}/${ENVIRONMENT_TOKEN}/secrets.env - | sed 's/^/export /')
fi

exec "$@"