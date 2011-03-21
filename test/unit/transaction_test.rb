require 'test_helper'

class TransactionTest < ActiveSupport::TestCase
  setup do
  end

  # Begin tests for Sales
  test "sales factory is valid" do
    assert Factory.build(:tr_sale).valid?
  end
  
  test "sale without gwtranid is not valid" do
    s = Factory.build(:tr_sale)
    s.gwtranid = nil
    assert_equal false, s.valid?
  end

  test "sales amount cannot be negative" do
    tr_sale = Factory.create(:tr_sale)
    assert_equal 'S', tr_sale.trantype
    assert tr_sale.valid?
    tr_sale.amount = -34
    assert_equal false, tr_sale.valid?
    tr_sale.amount = +34
    assert tr_sale.valid?
  end

  # Begin tests for Discounts
  test "discounts factory is valid" do
    assert Factory.build(:tr_discount).valid?
  end

  test "discount amount cannot be negative" do
    tr_discount = Factory.build(:tr_discount)
    assert_equal 'D', tr_discount.trantype
    assert tr_discount.valid?
    tr_discount.amount = -42
    assert_equal false, tr_discount.valid?
    tr_discount.amount = +42
    assert tr_discount.valid?
  end

end
