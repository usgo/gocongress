echo "Deploy staging .."
git push stage master
heroku run rake db:migrate --app gocongress-dev

echo "Deploy production .."
git push prod master
heroku run rake db:migrate --app gocongress

echo "Deploy complete"
