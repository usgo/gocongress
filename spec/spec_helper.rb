require 'rubygems'
require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require "rails/application"

  # Devise likes to load the User model. We want to avoid this.
  # It does so in the routes file, when calling devise_for().
  # The solution? Delay route loading.
  # https://github.com/sporkrb/spork/wiki/Spork.trap_method-Jujitsu
  Spork.trap_method(Rails::Application::RoutesReloader, :reload!)

  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'
  RSpec.configure do |config|
    config.use_transactional_fixtures = true
  end
end

Spork.each_run do
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
  require "#{ Rails.root }/config/routes"
  FactoryGirl.reload
end
