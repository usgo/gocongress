source 'http://rubygems.org'

# In order to use the release candidate, we must use the
# PessimisticVersionConstraint operator (~>)
# When Rails 3.1 stable is released, we should drop this version constraint
gem 'rails', '~> 3.1.0.rc4'

# Asset template engines
gem 'sass'
gem 'coffee-script'
gem 'uglifier'

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
	gem 'factory_girl'
	gem 'factory_girl_rails'
	
	# pretty console printing for tests
	# the 'redgreen' gem does not support ruby 1.9.2,
	# so we will try out the 'turn' gem
	gem 'turn'
end

# To keep your heroku slug size down, try this
# heroku config:add BUNDLE_WITHOUT="development:test"

# You need a javascript engine for rails 3.1 (heroku doesn't have one), and it
# appears that the javascript engine that works with Heroku is the rubyracer for
# heroku. Heroku has a stack now that comes with node.js which will take care of
# this issue when rails 3.1rc5 arrives
group :production do
  gem 'therubyracer-heroku', '0.8.1.pre3'
end
