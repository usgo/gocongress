#!/usr/bin/env bash
set -e

if [ -f .env ]; then
  source .env
fi

export GOCONGRESS_WAS_STARTED_BY_START_SH=true

bundle exec rails server
