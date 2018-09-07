#!/bin/bash

CS_INSTANCE="$1"
echo "Starting Cloud SQL Proxy..."
wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O cloud_sql_proxy
chmod +x cloud_sql_proxy
./cloud_sql_proxy -dir=/cloudsql -instances="${CS_INSTANCE}" &
sleep 3
echo "Cloud SQL Proxy started."
export DATABASE_HOST="/cloudsql/${CS_INSTANCE}"
echo "Use DATABASE_HOST: ${DATABASE_HOST} (this env var has been exported for you)."
echo "Cloud SQL socket(s) available in /cloudsql/ :"
ls -lFah /cloudsql
