source 'https://rubygems.org'

# Specify a ruby version
# http://gembundler.com/v1.2/whats_new.html
# https://devcenter.heroku.com/articles/ruby-versions
ruby '2.1.2'

gem 'rails', '4.1.5'

# View Layer
gem 'jquery-rails'
gem 'haml'
gem 'bluecloth' # markdown
gem 'kaminari' # pagination
gem 'sass-rails', '~> 4.0.2'
gem 'uglifier', '>= 1.3.0'

# Model Layer
gem 'pg'
gem 'protected_attributes'
gem 'validates_timeliness'

# Stack, middleware, engines, etc.
gem 'authorize-net'
gem 'cancan'
gem 'devise'
gem 'exception_notification', '~> 4.0.1'
gem 'thin'

# Deployment
gem 'asset_sync'
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
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'rspec-rails', '~> 3.0.0'
  gem 'rspec-mocks'
end

group :development do
  gem 'haml-rails'
  gem 'quiet_assets'
end

group :test do
  gem 'capybara'
  gem 'launchy' # provides `save_and_open_page`
	gem 'deep_merge' # recursively merge hashes
	gem 'factory_girl'
	gem 'factory_girl_rails'
  gem 'spork', '~> 1.0.0rc4' # rc4 has -q (quiet) option
	gem 'spork-rails'
	gem 'rb-fsevent'
end
