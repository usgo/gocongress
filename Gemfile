source 'https://rubygems.org'
ruby '2.5.7'

gem 'asset_sync'
gem 'authorizenet'
gem 'stripe'
gem 'stripe_event'
gem 'bluecloth', require: 'tilt/bluecloth'
gem 'cancancan'
gem 'devise'
gem 'exception_notification'
gem 'ffi'
gem 'fog-aws'
gem 'haml'
gem 'intl-tel-input-rails'
gem 'iso_country_codes'
gem 'jc-validates_timeliness'
gem 'jquery-rails'
gem 'kaminari'
gem 'nokogiri'
gem 'pg'
gem 'phonelib'
gem 'puma' # Heroku+Puma docs: https://bit.ly/3blHFc7
gem 'rails', '5.1.7'
gem 'sassc-rails' # see https://github.com/sass/sassc-rails/issues/114
gem 'sprockets', '< 4' # v4 has multiple issues
gem 'uglifier'
gem 'redcarpet'
gem 'unf' # <- fog <- asset_sync (http://bit.ly/17TiMjA)
gem 'twilio-ruby'
gem 'prettier'
gem 'mini_magick'

# rspec-rails wants to be in the :development group
# to "expose generators and rake tasks"
group :test, :development do
  gem 'dotenv-rails'
  gem 'rspec-rails'
  gem 'rubocop'
end

group :test do
  gem 'capybara'
  gem 'deep_merge' # recursively merge hashes
  gem 'database_cleaner'
  gem 'factory_bot'
  gem 'factory_bot_rails'
  gem 'launchy' # provides `save_and_open_page`
  gem 'rails-controller-testing'
  gem 'rb-fsevent'
  gem 'vcr'
  gem 'webmock'
end
