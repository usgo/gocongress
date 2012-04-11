heroku maintenance:on --app gocongress
git push prod master
heroku run rake db:migrate --app gocongress
heroku maintenance:off --app gocongress
