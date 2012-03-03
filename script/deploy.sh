echo "Deploy staging .."
heroku maintenance:on --app gocongress-dev
git push stage master
heroku run rake db:migrate --app gocongress-dev
heroku maintenance:off --app gocongress-dev

echo "Deploy production .."
heroku maintenance:on --app gocongress
git push prod master
heroku run rake db:migrate --app gocongress
heroku maintenance:off --app gocongress

echo "Deploy complete"
