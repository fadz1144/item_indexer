#!/usr/bin/env bash

bin/configure_gae_firewall.sh

echo '[Deployment] Running resque worker task...'
bundle exec rails resque:work QUEUE=*
