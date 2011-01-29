require 'test_helper'

class TransactionTest < ActiveSupport::TestCase
  setup do
    @transaction = Factory.create(:transaction)
  end

  test "factory is valid" do
    assert Factory.build(:transaction).valid?
  end

  test "sales amount can not be negative" do
    @transaction.trantype = 'S'
    @transaction.amount = -34
    assert_equal false, @transaction.valid?
  end
end
