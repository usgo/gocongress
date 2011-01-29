require 'test_helper'

class JobTest < ActiveSupport::TestCase
  test "factory is valid" do
    assert Factory.build(:job).valid?
  end
end
