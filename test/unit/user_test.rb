require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "factory is valid" do
    assert Factory.build(:user).valid?
  end
end
