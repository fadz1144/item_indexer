#!/usr/bin/env bash
echo 'Configure App Engine Firewall (Ensuring all instances are allowed for RPC purposes)...'
bundle exec rake bridge_cloud:app_engine:add_all_instances_to_firewall
echo "Running resque worker task..."
bundle exec rails resque:work QUEUE=*
