source 'http://rubygems.org'

gem 'rails'

# Database
# To install the 'pg' gem, the postgres bin directory must be on your path
# export PATH=/path/to/postgres/bin:${PATH}
gem 'pg'

# Asset template engines
gem 'sass'
gem 'coffee-script'
gem 'uglifier'
gem "jquery-rails" # jquery and jquery-ui
gem 'validates_timeliness'
gem 'haml'
gem 'haml-rails', :group => :development
gem 'hoptoad_notifier' # uncaught exception notification
gem 'bluecloth' # markdown
gem 'kaminari' # pagination

# AAA - Authentication, Authorization, and Access Control
gem 'devise' # authentication
gem 'cancan' # authorization and access control

# After migrating to Cedar, Heroku recommends thin over webrick
gem 'thin'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'rcov'
end

# Testing
group :test do
	gem 'factory_girl'
	gem 'factory_girl_rails'
end

# To keep your heroku slug size down, try this
# heroku config:add BUNDLE_WITHOUT="development:test"
