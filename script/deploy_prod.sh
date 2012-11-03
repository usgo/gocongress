git push prod master
bundle exec heroku maintenance:on --app gocongress
bundle exec heroku run rake db:migrate --app gocongress
bundle exec heroku maintenance:off --app gocongress
