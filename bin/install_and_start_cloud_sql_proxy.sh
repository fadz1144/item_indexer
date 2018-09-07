#!/bin/bash

CS_INSTANCE="$1"
echo "Starting Cloud SQL Proxy..."
curl -o cloud_sql_proxy "https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64"
chmod +x cloud_sql_proxy
mkdir /cloudsql && chmod 777 /cloudsql
./cloud_sql_proxy -dir=/cloudsql -instances="${CS_INSTANCE}" -credential_file=/secrets/cloudsql/credentials.json &
sleep 3
echo "Cloud SQL Proxy started."
DATABASE_HOST="/cloudsql/${CS_INSTANCE}"
echo "export DATABASE_HOST=${DATABASE_HOST}" > dbhost.sh

echo "Use DATABASE_HOST: ${DATABASE_HOST} (source dbhost.sh to get this)"
echo "Cloud SQL socket(s) available in /cloudsql/ :"
ls -lFah /cloudsql
