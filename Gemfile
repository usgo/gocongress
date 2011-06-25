source 'http://rubygems.org'

gem 'rails'
gem 'sqlite3-ruby', :require => 'sqlite3'
gem "jquery-rails" # jquery and jquery-ui
gem "devise" # authentication
gem 'validates_timeliness'
gem 'haml'
gem 'haml-rails', :group => :development 
gem 'fastercsv'
gem 'hoptoad_notifier' # uncaught exception notification
gem 'bluecloth' # markdown
gem 'kaminari' # pagination

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'rspec-rails', '~> 2.0'
  gem 'rcov'
end

group :test do
	gem 'factory_girl', '~>1.3.2'
	gem 'factory_girl_rails'
	
	# pretty console printing for tests
	# the 'redgreen' gem does not support ruby 1.9.2,
	# so we will try out the 'turn' gem
	gem 'turn'
end

# To keep your heroku slug size down, try this
# heroku config:add BUNDLE_WITHOUT="development:test"
