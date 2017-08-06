source 'https://rubygems.org'
ruby '2.4.1'

gem 'asset_sync'
gem 'authorizenet'
gem 'bluecloth', require: 'tilt/bluecloth'
gem 'cancancan', '~> 1.9'
gem 'devise'
gem 'exception_notification'
gem 'fog-aws'
gem 'haml'
gem 'jc-validates_timeliness'
gem 'jquery-rails'
gem 'kaminari'
gem 'pg'
gem 'protected_attributes'
gem 'rails', '4.2.9'
gem 'responders', '~> 2.0'
gem 'sass-rails'
gem 'thin'
gem 'uglifier', '>= 1.3.0'
gem 'unf' # <- fog <- asset_sync (http://bit.ly/17TiMjA)

# Groups: Rails will load the group where name == Rails.env
# http://yehudakatz.com/2010/05/09/the-how-and-why-of-bundler-groups/
#
# To keep your heroku slug size down, heroku automatically
# bundles --without development:test
# https://blog.heroku.com/archives/2011/2/15/using-bundler-groups-on-heroku

# Heroku gems hopefully replace plugins.
# https://devcenter.heroku.com/articles/rails4#heroku-gems
# Unfortunately, heroku still injects plugins.
# But that should be fixed soon by:
# https://github.com/heroku/heroku-buildpack-ruby/pull/11
# Then again, do I really want serve_static_assets?
group :production, :stage do
  gem 'rails_12factor'
end

# rspec-rails wants to be in the :development group
# to "expose generators and rake tasks"
group :test, :development do
  gem 'dotenv-rails'
  gem 'rspec-rails'
  gem 'rubocop'
end

group :development do
  gem 'haml-rails'
  gem 'quiet_assets'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'web-console', '~> 3.0'
end

group :test do
  gem 'capybara'
  gem 'deep_merge' # recursively merge hashes
  gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'launchy' # provides `save_and_open_page`
  gem 'rb-fsevent'
end
