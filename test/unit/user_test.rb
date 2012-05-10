require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = FactoryGirl.create :user
  end

  test "comp transaction" do
    @user.transactions << FactoryGirl.create(:tr_comp, :user_id => @user.id, :amount => 33)
    @user.transactions << FactoryGirl.create(:tr_comp, :user_id => @user.id, :amount => 40)
    assert_equal -73, @user.get_invoice_total
  end

  test "amount paid is sum of sale transactions" do
    num_transactions = 10
    expected_sum = 0
    1.upto(num_transactions) { |n|
      t = FactoryGirl.create(:tr_sale, :user_id => @user.id)
      expected_sum += t.amount
      @user.transactions << t
      }
    assert_equal num_transactions, @user.transactions.where(:trantype => 'S').length
    assert_equal expected_sum, @user.amount_paid
  end

  test "balance" do
    1.upto(1+rand(3)) { |a| @user.attendees << FactoryGirl.create(:attendee, :user_id => @user.id) }
    1.upto(1+rand(10)) { |n| @user.transactions << FactoryGirl.create(:tr_sale, :user_id => @user.id) }
    1.upto(1+rand(5)) { |n| @user.transactions << FactoryGirl.create(:tr_comp, :user_id => @user.id) }
    assert_equal @user.get_invoice_total - @user.amount_paid, @user.balance
  end

  test "sum of invoice equals invoice total" do
    1.upto(1+rand(3)) { |a| @user.attendees << FactoryGirl.create(:attendee, :user_id => @user.id) }
    expected_sum = 0
    @user.get_invoice_items.each { |ii| expected_sum += ii.price }
    assert_equal expected_sum, @user.get_invoice_total
  end

  test "destroying a user also destroys dependent attendees" do
    num_extra_attendees = 1 + rand(3)
    1.upto(num_extra_attendees) { |a|
      @user.attendees << FactoryGirl.create(:attendee, :user_id => @user.id)
    }

    # when we destroy the user, we expect all dependent attendees
    # to be destroyed, including the primary_attendee
    expected_difference = -1 * (num_extra_attendees + 1)
    destroyed_user_id = @user.id
    assert_difference 'Attendee.count', expected_difference do
      @user.destroy
    end

    # double check
    assert_equal 0, Attendee.where(:user_id => destroyed_user_id).count
  end

  test "age-based discounts" do
    y = Time.now.year
    dc = FactoryGirl.create(:discount, :name => "Child", :amount => 150, :age_min => 0, :age_max => 12, :is_automatic => true, :year => y)
    dy = FactoryGirl.create(:discount, :name => "Youth", :amount => 100, :age_min => 13, :age_max => 18, :is_automatic => true, :year => y)
    congress_start = CONGRESS_START_DATE[y]

    # If 12 years old on the first day of congress, then attendee
    # should get child discount and NOT youth discount
    a = FactoryGirl.create(:minor, :birth_date => congress_start - 12.years, :user_id => @user.id, :year => y)
    assert_equal 12, a.age_in_years
    assert_equal true, user_has_discount?(@user, dc)
    assert_equal false, user_has_discount?(@user, dy)

    # 11 year old should get child discount and NOT youth discount
    a.update_attribute :birth_date, congress_start - 11.years
    assert_equal 11, a.age_in_years.truncate, "Expected (#{a.age_in_years}).truncate to equal 11.  The birth_date is #{11.years.ago}"
    @user.reload
    assert_equal true, user_has_discount?(@user, dc)
    assert_equal false, user_has_discount?(@user, dy)

    # 13 year old should get YOUTH discount, not child discount
    a.update_attribute :birth_date, congress_start - 13.years
    assert_equal 13, a.age_in_years.truncate
    @user.reload
    assert_equal false, user_has_discount?(@user, dc)
    assert_equal true, user_has_discount?(@user, dy)
  end

  test "plan with qty increases invoice total" do
    @user.attendees << FactoryGirl.create(:attendee, :user_id => @user.id)
    total_before = @user.get_invoice_total

    # add a plan with qty > 1 to attendee
    p = FactoryGirl.create :plan, :max_quantity => 10 + rand(10)
    qty = 1 + rand(p.max_quantity)
    ap = AttendeePlan.new :plan_id => p.id, :quantity => qty
    @user.attendees.first.attendee_plans << ap

    # assert that user's inv. item total increases by price * qty
    expected = (total_before + qty * p.price).to_f
    actual = @user.get_invoice_total.to_f
    assert_in_delta expected, actual, 0.001, "user total should increase by price * qty"

    # change plan qty by 1, assert that invoice total changes by price
    expected = @user.get_invoice_total + p.price
    ap.quantity += 1
    assert_in_delta expected, @user.get_invoice_total, 0.001, "increase qty should increase price"
  end

  test "attendee cannot provide qty greater than plan max_qty" do
    a = FactoryGirl.create :attendee, :user_id => @user.id
    p = FactoryGirl.create :plan, :max_quantity => 1
    ap = AttendeePlan.new :plan_id => p.id, :quantity => p.max_quantity + 1, :attendee_id => a.id
    assert_equal false, ap.valid?
  end

  test "activity increases invoice total" do
    e = FactoryGirl.create :activity
    assert_difference('@user.get_invoice_total', e.price) do
      @user.attendees.first.activities << e
    end
  end

private

  def user_has_discount? (user, discount)
    user.get_invoice_items.map(&:description).include?(discount.get_invoice_item_name)
  end

end
