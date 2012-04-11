heroku maintenance:on --app gocongress-dev
git push stage master
heroku run rake db:migrate --app gocongress-dev
heroku maintenance:off --app gocongress-dev
