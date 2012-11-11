#!/bin/bash
set -e

echo -n 'rb: '
find . -name '*.rb' | egrep -v 'db/migrate' | xargs wc -l | tail -n 1

echo -n 'scss: '
find app/assets/stylesheets -name '*.scss' | xargs wc -l | tail -n 1

echo -n 'js: '
find app/assets/javascripts -name '*.js' | xargs wc -l | tail -n 1
