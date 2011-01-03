ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionController::TestCase
 include Devise::TestHelpers

 def setup
   # Tell Devise what model we're using for Auth.  Make sure only to add this
   # to tests that inherit from ActionController::TestCase
   request.env["devise.mapping"] = Devise.mappings[:user]
 end

end
