#!/usr/bin/bash

# Create a user using the create_user.rb script but using a docker run to create this within the app_database.
docker-compose run app bash -c "rails db:environment:set RAILS_ENV=development && rake db:setup && rails runner script/admin_tasks/create_user.rb"
