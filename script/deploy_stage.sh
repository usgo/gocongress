git push stage master
heroku maintenance:on --app gocongress-dev
heroku run rake db:migrate --app gocongress-dev
heroku maintenance:off --app gocongress-dev
