#!/usr/bin/env bash
set -e

# used to run resque worker and resque scheduler
if [[ -n "${OVERRIDE_COMMAND}" ]] ; then
    echo "[Deployment] *** About to run override command: ${OVERRIDE_COMMAND}"
    eval "${OVERRIDE_COMMAND}"
    echo "[Deployment] *** The command has exited. The container will now exit :)"
    exit 0
fi

# the deployment scripts come from the deployment-scripts image which is built in the bridge-deploy repo (see COPY
# command in Dockerfile)
bin/start_nginx.sh
bin/report_deployment_to_honeybadger.sh item_indexer /bbb/app || true
bin/configure_gae_firewall.sh
bin/prepare_database_rake.sh
export RAILS_RELATIVE_URL_ROOT='/item_indexer'
bin/start_puma.sh
