require 'test_helper'

class TransactionTest < ActiveSupport::TestCase
  setup do
  end

  # Begin tests for Sales
  test "sales factory is valid" do
    assert Factory.build(:tr_sale).valid?
  end

  test "sale with card requires gwdate and gwtranid" do
    s = Factory.build(:tr_sale, :instrument => 'C', :gwdate => nil)
    assert_equal false, s.valid?
    s = Factory.build(:tr_sale, :instrument => 'C', :gwtranid => nil)
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

  # Begin tests for comps
  test "comps factory is valid" do
    t = Factory.build(:tr_comp)
    assert t.valid?, t.errors.full_messages.join(',')
  end
  
  test "comp with gwtranid is not valid" do
    tr_comp = Factory.build(:tr_comp)
    tr_comp.gwtranid = 12897
    assert_equal false, tr_comp.valid?
  end
  
  test "comp with gwdate is not valid" do
    tr_comp = Factory.build(:tr_comp)
    tr_comp.gwdate = Time.now.to_date
    assert_equal false, tr_comp.valid?
  end

  test "comp amount cannot be negative" do
    tr_comp = Factory.build(:tr_comp)
    assert_equal 'C', tr_comp.trantype
    assert tr_comp.valid?
    tr_comp.amount = -42
    assert_equal false, tr_comp.valid?
    tr_comp.amount = +42
    assert tr_comp.valid?
  end

end
