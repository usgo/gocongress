source 'http://rubygems.org'

# Core rails stuff
gem 'rails'
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'

# Database
# To install the 'pg' gem, the postgres bin directory must be on your path
# export PATH=/path/to/postgres/bin:${PATH}
gem 'pg'

# View Layer
gem "jquery-rails" # jquery and jquery-ui
gem 'haml'
gem 'haml-rails', :group => :development
gem 'bluecloth' # markdown
gem 'kaminari' # pagination

# AAA - Authentication, Authorization, and Access Control
gem 'devise'
gem 'cancan'

# Model Layer
gem 'ranked-model'
gem 'validates_timeliness'

# uncaught exception notification
gem 'exception_notification'

# After migrating to Cedar, Heroku recommends thin over webrick
gem 'thin'

# A simple helper to get an HTML select list of countries.
# The jaredbeck fork uses ISO 3166-1 alpha-2 codes as option values,
# instead of the full country names.
gem 'country-select', :git => 'git://github.com/jaredbeck/country-select.git'

# rspec-rails wants to be in the :development group
# to "expose generators and rake tasks"
group :test, :development do
  gem 'rspec-rails'
  gem 'rspec-mocks'
end

# Testing only
group :test do
	gem 'factory_girl'
	gem 'factory_girl_rails'
	gem 'spork', '1.0.0rc3'
	gem 'spork-rails'
end

# To keep your heroku slug size down, try this
# heroku config:add BUNDLE_WITHOUT="development:test"
