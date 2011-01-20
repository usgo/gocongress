require 'test_helper'

class TransactionTest < ActiveSupport::TestCase
  test "factory is valid" do
    assert Factory.build(:transaction).valid?
  end
end
