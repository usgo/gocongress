source 'https://rubygems.org'

# Specify a ruby version
# http://gembundler.com/v1.2/whats_new.html
# https://devcenter.heroku.com/articles/ruby-versions
ruby '1.9.3'

# Core rails stuff
gem 'rails', '~> 3.2.13'
gem 'sass-rails', '~> 3.2.6'
# gem 'coffee-rails'
gem 'uglifier'

# Database
# To install the 'pg' gem, the postgres bin directory must be on your path
# export PATH=/path/to/postgres/bin:${PATH}
gem 'pg'

# View Layer
gem "jquery-rails"
gem 'haml'
gem 'bluecloth' # markdown
gem 'kaminari' # pagination
gem 'asset_sync'

# For some reason, bundle update was downgrading fog to 0.9 even though
# here are no constraints on fog in the Gemfile.lock.  So, I have to
# require `1.12` here.
gem 'fog', '~> 1.12.1'

# AAA - Authentication, Authorization, and Access Control
gem 'devise'
gem 'cancan'

# Payments
gem 'authorize-net'

# Model Layer
gem 'validates_timeliness'

# uncaught exception notification
gem 'exception_notification', '~> 3.0.1'

# After migrating to Cedar, Heroku recommends thin over webrick
gem 'thin'

# A simple helper to get an HTML select list of countries.
# The jaredbeck fork uses ISO 3166-1 alpha-2 codes as option values,
# instead of the full country names.
gem 'country-select', :git => 'git://github.com/jaredbeck/country-select.git'

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
  gem 'rails_log_stdout', github: 'heroku/rails_log_stdout'
  gem 'rails3_serve_static_assets', github: 'heroku/rails3_serve_static_assets'
end

# rspec-rails wants to be in the :development group
# to "expose generators and rake tasks"
group :test, :development do
  gem 'dotenv-rails'
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'rspec-rails'
  gem 'rspec-mocks'
end

group :development do
  gem 'haml-rails'
  gem 'quiet_assets'

  # I love these two tools, but they use `sexp_processor` which defines
  # a `s` method in the global namespace.  This is too much pollution
  # for my taste.  So, I install the gems, but not in my bundle. -Jared 2013
  # gem 'html2haml'
  # gem 'flog'
end

group :test do
  gem 'capybara'
  gem 'launchy' # provides `save_and_open_page`
	gem 'deep_merge' # recursively merge hashes
	gem 'factory_girl'
	gem 'factory_girl_rails'
	gem 'spork-rails'
	gem 'rb-fsevent'

	# Using edge spork solely to get the -q (quiet) option so that
	# we can pass :quiet => true to guard 'spork'.  Before this,
	# I had been using spork 1.0.0rc3
	gem 'spork', :git => 'https://github.com/sporkrb/spork.git'
end
