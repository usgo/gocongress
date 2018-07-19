# this will be useful when we upgrade to Rails 5.1
# which has support for system tests
RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end
end
