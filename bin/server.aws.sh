#!/usr/bin/env bash
set -e
nginx
echo "nginx started"
rm -f /okl/app/tmp/pids/puma.pid
echo "About to start db:create"
bundle exec rails db:create
echo "DB create complete. About to start db:migrate"
bundle exec rails db:migrate
echo 'DB actions complete.'
echo 'Reporting deployment in Honeybadger...'
/okl/app/bin/deploy_notify.sh item_indexer /okl/app || true
echo 'Running puma...'
export RAILS_RELATIVE_URL_ROOT='/item_indexer'
bundle exec puma -C config/puma.rb -b unix:///var/run/puma.sock
