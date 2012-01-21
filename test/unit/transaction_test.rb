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

  test "#description" do
    t = Factory.build(:tr_comp, :comment => "foobar")
    assert_equal "Comp: foobar", t.description
    t.comment = nil
    assert_equal "Comp", t.description
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

  test "comp transaction instrument must be blank" do
    c = Factory.build(:tr_comp, :instrument => nil)
    assert c.valid?, "nil instrument should be valid"
    c = Factory.build(:tr_comp, :instrument => '')
    assert c.valid?, "emptystring instrument should be valid"
    %w[C S K].each do |i|
      c = Factory.build(:tr_comp, :instrument => i)
      assert_equal false, c.valid?, "if instrument is present, comp transaction should be invalid"
    end
  end

  test "unreasonable years are invalid" do
    t = Factory.build(:tr_sale)
    assert t.valid?
    t.year = nil
    assert_equal false, t.valid?
    t.year = 2100
    assert_equal false, t.valid?
    t.year = 2010
    assert_equal false, t.valid?
    t.year = 2011
    assert t.valid?
  end
  
  test "yr" do
    assert Transaction.respond_to?(:yr)
    (rand(4)+1).times { Factory.create(:tr_sale, :year => 2011) }
    (rand(4)+1).times { Factory.create(:tr_sale, :year => 2012) }
    assert_equal Transaction.where(:year => 2011).count, Transaction.yr(2011).count
    assert_equal Transaction.where(:year => 2012).count, Transaction.yr(2012).count
  end

end
