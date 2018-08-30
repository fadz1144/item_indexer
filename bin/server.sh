#!/usr/bin/env bash
set -e
echo "Starting nginx web server..."
nginx
echo "nginx started"
mkdir -p /bbb/app/tmp/pids
rm -f /bbb/app/tmp/pids/puma.pid
echo "About to start db:create"
bundle exec rails db:create
echo "DB create complete. About to start db:migrate"
bundle exec rails db:migrate
bundle exec rails db:version
echo 'DB actions complete.'
if [[ "$RACK_ENV" = "production" ]] || [[ "$RAILS_ENV" = "production" ]] ; then
    echo 'Reporting deployment in Honeybadger...'
    /bbb/app/bin/deploy_notify.sh item_indexer /bbb/app || true

    echo 'Configure App Engine Firewall (Ensuring all instances are allowed for RPC purposes)...'
    bundle exec rake bridge_cloud:app_engine:add_all_instances_to_firewall
fi
echo "Starting puma application server..."
export RAILS_RELATIVE_URL_ROOT='/item_indexer'
bundle exec puma -C config/puma.rb -b unix:///var/run/puma.sock
