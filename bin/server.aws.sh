#!/usr/bin/env bash
set -e
echo "Starting nginx as a proxy to send traffic to bbbycatalog.us:"
nginx
echo "Nginx has exited!"
nginx -T
