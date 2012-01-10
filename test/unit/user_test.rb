require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = Factory :user
  end

  test "factory is valid" do
    assert Factory.build(:user).valid?
  end

  test "comp transaction" do
    @user.transactions << Factory(:tr_comp, :user_id => @user.id, :amount => 33)
    @user.transactions << Factory(:tr_comp, :user_id => @user.id, :amount => 40)
    assert_equal -73, @user.get_invoice_total
  end

  test "amount paid is sum of sale transactions" do
    num_transactions = 10
    expected_sum = 0
    1.upto(num_transactions) { |n|
      t = Factory(:tr_sale, :user_id => @user.id)
      expected_sum += t.amount
      @user.transactions << t
      }
    assert_equal num_transactions, @user.transactions.where(:trantype => 'S').length
    assert_equal expected_sum, @user.amount_paid
  end

  test "balance" do
    1.upto(1+rand(3)) { |a| @user.attendees << Factory(:attendee, :user_id => @user.id) }
    1.upto(1+rand(10)) { |n| @user.transactions << Factory(:tr_sale, :user_id => @user.id) }
    1.upto(1+rand(5)) { |n| @user.transactions << Factory(:tr_comp, :user_id => @user.id) }
    assert_equal @user.get_invoice_total - @user.amount_paid, @user.balance
  end

  test "sum of invoice equals invoice total" do
    1.upto(1+rand(3)) { |a| @user.attendees << Factory(:attendee, :user_id => @user.id) }
    expected_sum = 0
    @user.get_invoice_items.each { |ii| expected_sum += ii['item_price'] }
    assert_equal expected_sum, @user.get_invoice_total
  end

  test "destroying a user also destroys dependent attendees" do
    num_extra_attendees = 1 + rand(3)
    1.upto(num_extra_attendees) { |a|
      @user.attendees << Factory(:attendee, :user_id => @user.id)
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
    dc = Factory(:discount, :name => "Child", :amount => 150, :age_min => 0, :age_max => 12, :is_automatic => true, :year => y)
    dy = Factory(:discount, :name => "Youth", :amount => 100, :age_min => 13, :age_max => 18, :is_automatic => true, :year => y)
    congress_start = CONGRESS_START_DATE[y]
    
    # If 12 years old on the first day of congress, then attendee
    # should get child discount and NOT youth discount
    a = Factory(:attendee, :birth_date => congress_start - 12.years, :user_id => @user.id, :understand_minor => true, :year => y)
    assert_equal 12, a.age_in_years
    assert_equal true, find_item_description?(@user.get_invoice_items, dc.get_invoice_item_name)
    assert_equal false, find_item_description?(@user.get_invoice_items, dy.get_invoice_item_name)

    # 11 year old should get child discount and NOT youth discount
    a.update_attribute :birth_date, congress_start - 11.years
    assert_equal 11, a.age_in_years.truncate, "Expected (#{a.age_in_years}).truncate to equal 11.  The birth_date is #{11.years.ago}"
    @user.reload
    assert_equal true, find_item_description?(@user.get_invoice_items, dc.get_invoice_item_name)
    assert_equal false, find_item_description?(@user.get_invoice_items, dy.get_invoice_item_name)

    # 13 year old should get YOUTH discount, not child discount
    a.update_attribute :birth_date, congress_start - 13.years
    assert_equal 13, a.age_in_years.truncate
    @user.reload
    assert_equal false, find_item_description?(@user.get_invoice_items, dc.get_invoice_item_name)
    assert_equal true, find_item_description?(@user.get_invoice_items, dy.get_invoice_item_name)
  end

  test "plan with qty increases invoice total" do
    @user.attendees << Factory(:attendee, :user_id => @user.id)
    total_before = @user.get_invoice_total

    # add a plan with qty > 1 to attendee
    p = Factory :plan, :max_quantity => 10 + rand(10)
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
    a = Factory :attendee, :user_id => @user.id
    p = Factory :plan, :max_quantity => 1
    ap = AttendeePlan.new :plan_id => p.id, :quantity => p.max_quantity + 1, :attendee_id => a.id
    assert_equal false, ap.valid?
  end

  test "event increases invoice total" do
    @user.attendees << Factory(:attendee, :user_id => @user.id)
    event_price = 10
    assert_difference('@user.get_invoice_total', event_price) do
      @user.attendees.first.events << Factory(:event, :evtprice => event_price.to_s)
    end
  end

  test "event with non-numeric price does not increase the invoice total" do
    @user.attendees << Factory(:attendee, :user_id => @user.id)
    
    # bypass validations to create event with non-numeric price
    event_with_bad_price = Factory(:event)
    event_with_bad_price.update_attribute :evtprice, "TBA"
    
    assert_no_difference('@user.get_invoice_total') do
      @user.attendees.first.events << event_with_bad_price
    end
  end

private
  
  def find_item_description? (items, description)
    found_description = false
    items.each do |i|
      if i['item_description'] == description then
        found_description = true
      end
    end
    return found_description
  end

end
