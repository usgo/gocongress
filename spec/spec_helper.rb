require 'rubygems'
require 'spork'
require 'capybara/rspec'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require "rails/application"

  # Devise likes to load the User model. We want to avoid this.
  # It does so in the routes file, when calling devise_for().
  # The solution? Delay route loading.
  # https://github.com/sporkrb/spork/wiki/Spork.trap_method-Jujitsu
  Spork.trap_method(Rails::Application::RoutesReloader, :reload!)

  require File.expand_path("../../config/environment", __FILE__)
  require 'rails/test_help'

  require 'rspec/rails'
  require 'rspec/autorun'
  RSpec.configure do |conf|
    conf.use_transactional_fixtures = true
    conf.filter_run :focus => true
    conf.run_all_when_everything_filtered = true
    conf.include FactoryGirl::Syntax::Methods
  end
end

Spork.each_run do
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f} # why?
  require "#{ Rails.root }/config/routes" # why?
  FactoryGirl.reload # why?
end

# We want mass_assignment_sanitizer = :strict, but our factories
# give include protected attributes.  This is a workaround until
# factory_girl can come up with something official.
# -Jared 2012-10-14
#
# http://www.ruby-forum.com/topic/3536091
# http://bit.ly/V0nC20
# https://gist.github.com/3437893
# https://github.com/thoughtbot/factory_girl/issues/408
#
def accessible_attributes_for resource
  if resource.is_a? Symbol
    klass = build(resource).class
    attrs = attributes_for resource
  else
    klass = resource.class
    attrs = resource.attributes
  end
  accessibles = klass.accessible_attributes
  attrs.symbolize_keys.keep_if { |k,v| accessibles.include?(k) }
end

# Custom RSpec matchers

RSpec::Matchers.define :have_error_about do |attribute|
  match do |subject|
    !subject.valid? && subject.errors.has_key?(attribute)
  end
end
