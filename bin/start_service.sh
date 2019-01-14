#!/usr/bin/env bash
set -e

if [[ -n "${CLOUD_SQL_PROXY_INSTANCE}" ]] ; then
    bin/install_and_start_cloud_sql_proxy.sh "${CLOUD_SQL_PROXY_INSTANCE}"
    source dbhost.sh
    env | grep DATABASE_HOST
fi

if [[ "${RUNTIME_ENV}" == "kube" ]] ; then
    echo '[Deployment] Swapping Redis to internal IP because we are running in K8'
    export REDIS_HOST=${REDIS_INTERNAL_HOST}
fi

# used to run resque worker and resque scheduler
if [[ -n "${OVERRIDE_COMMAND}" ]] ; then
    echo "[Deployment] *** About to run override command: ${OVERRIDE_COMMAND}"
    eval "${OVERRIDE_COMMAND}"
    echo "[Deployment] *** The command has exited. The container will now exit :)"
    exit 0
fi

bin/start_nginx.sh
bin/report_deployment_to_honeybadger.sh item_indexer /bbb/app || true
bin/configure_gae_firewall.sh
bin/prepare_database_rake.sh
export RAILS_RELATIVE_URL_ROOT='/item_indexer'
bin/start_puma.sh

