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

# Asset template engines
gem "jquery-rails" # jquery and jquery-ui
gem 'validates_timeliness'
gem 'haml'
gem 'haml-rails', :group => :development
gem 'airbrake' # uncaught exception notification
gem 'bluecloth' # markdown
gem 'kaminari' # pagination

# AAA - Authentication, Authorization, and Access Control
gem 'devise', "~> 1.5" # not ready for devise 2.0 yet
gem 'cancan'

# After migrating to Cedar, Heroku recommends thin over webrick
gem 'thin'

# A simple helper to get an HTML select list of countries.
# The jaredbeck fork uses ISO 3166-1 alpha-2 codes as option values,
# instead of the full country names.
gem 'country-select', :git => 'git://github.com/jaredbeck/country-select.git'

# Testing
group :test do
	gem 'factory_girl'
	gem 'factory_girl_rails'
end

# To keep your heroku slug size down, try this
# heroku config:add BUNDLE_WITHOUT="development:test"
