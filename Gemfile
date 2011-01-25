source 'http://rubygems.org'

gem 'rails', '3.0.3'
gem 'sqlite3-ruby', :require => 'sqlite3'

gem "jquery-rails"
gem "devise"

gem 'haml'
gem 'haml-rails', :group => :development 

# bluecloth is a markdown library
gem 'bluecloth'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'rspec-rails', '~> 2.0'
end

# redgreen does console coloring for tests
group :test do
	gem 'factory_girl', '~>1.3.2'
	gem 'factory_girl_rails'
	gem 'redgreen'
end
