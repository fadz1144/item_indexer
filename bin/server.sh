#!/usr/bin/env bash
echo "Starting nginx web server..." && \
nginx && \
mkdir -p /okl/app/tmp/pids && \
rm -f /okl/app/tmp/pids/puma.pid && \
echo -n "DB " && \
rake db:create && \
rake db:migrate && \
rake db:version && \
echo "Starting puma application server..." && \
export RAILS_RELATIVE_URL_ROOT='/item_indexer' && \
bundle exec puma -e production -b unix:///var/run/puma.sock
