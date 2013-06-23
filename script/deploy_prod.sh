set -e
git push prod master
heroku maintenance:on --app gocongress
heroku run rake db:migrate --app gocongress
heroku maintenance:off --app gocongress
