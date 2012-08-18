bundle exec heroku maintenance:on --app gocongress-dev
git push stage master
bundle exec heroku run rake db:migrate --app gocongress-dev
bundle exec heroku maintenance:off --app gocongress-dev
