require 'test_helper'

class TransactionTest < ActiveSupport::TestCase

  # sales
  test "sales amount cannot be negative" do
    tr_sale = FactoryGirl.create(:tr_sale)
    assert_equal 'S', tr_sale.trantype
    assert tr_sale.valid?
    tr_sale.amount = -34
    assert_equal false, tr_sale.valid?
    tr_sale.amount = +34
    assert tr_sale.valid?
  end

  # comps
  test "#description" do
    t = FactoryGirl.build(:tr_comp, :comment => "foobar")
    assert_equal "Comp: foobar", t.description
    t.comment = nil
    assert_equal "Comp", t.description
  end

  test "comp with gwtranid is not valid" do
    tr_comp = FactoryGirl.build(:tr_comp)
    tr_comp.gwtranid = 12897
    assert_equal false, tr_comp.valid?
  end

  test "comp with gwdate is not valid" do
    tr_comp = FactoryGirl.build(:tr_comp)
    tr_comp.gwdate = Time.now.to_date
    assert_equal false, tr_comp.valid?
  end

  test "comp amount cannot be negative" do
    tr_comp = FactoryGirl.build(:tr_comp)
    assert_equal 'C', tr_comp.trantype
    assert tr_comp.valid?
    tr_comp.amount = -42
    assert_equal false, tr_comp.valid?
    tr_comp.amount = +42
    assert tr_comp.valid?
  end

  test "comp transaction instrument must be blank" do
    c = FactoryGirl.build(:tr_comp, :instrument => nil)
    assert c.valid?, "nil instrument should be valid"
    c = FactoryGirl.build(:tr_comp, :instrument => '')
    assert c.valid?, "emptystring instrument should be valid"
    %w[C S K].each do |i|
      c = FactoryGirl.build(:tr_comp, :instrument => i)
      assert_equal false, c.valid?, "if instrument is present, comp transaction should be invalid"
    end
  end

end
