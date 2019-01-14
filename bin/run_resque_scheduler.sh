#!/usr/bin/env bash

bin/configure_gae_firewall.sh

echo '[Deployment] Running resque scheduler task...'
bundle exec rails resque:scheduler
