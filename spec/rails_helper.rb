ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

# If someone is running the test suite in the wrong env, we want to catch that
# very early, before any damage can be done. A `before(:suite)` hook might be
# too late.
unless Rails.env.test?
  abort format('Invalid env. for tests: %s', Rails.env)
end

require 'spec_helper'
require 'rspec/rails'
require 'capybara/rspec'
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
ActiveRecord::Migration.maintain_test_schema!
RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include FactoryBot::Syntax::Methods
  config.before(:suite) do
    if Year.find_by(year: CONGRESS_YEAR).nil?
      abort format('Year not found: %d: Try db:test:prepare', CONGRESS_YEAR)
    end
  end
end

# TODO: use rspec helper method instead of global method
def accessible_attributes_for(resource)
  if resource.is_a? Symbol
    klass = build(resource).class
    attrs = attributes_for resource
  else
    klass = resource.class
    attrs = resource.attributes
  end
  accessibles = klass.accessible_attributes
  attrs.symbolize_keys.keep_if { |k, _v| accessibles.include?(k) }
end

RSpec::Matchers.define :have_error_about do |attribute|
  match do |subject|
    !subject.valid? && subject.errors.has_key?(attribute)
  end
end
