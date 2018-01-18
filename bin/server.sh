#!/usr/bin/env bash
rm -f /okl/app/tmp/pids/puma.pid && bundle exec puma -C config/puma.rb -b tcp://0.0.0.0 -p 3000
