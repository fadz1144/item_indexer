#!/usr/bin/env bash
bundle exec rails resque:work QUEUE=*
