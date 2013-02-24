#!/usr/bin/env bash
set -e

if [ -f .env ]; then
  source .env
fi

bundle exec rails server
