require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "factory is valid" do
    assert Factory.build(:user).valid?
  end

  test "user (playing) with N go-playing attendees owes N * 375 dollars" do
    u = Factory(:user)
    u.primary_attendee.is_player = true
    u.save
    num_extra_attendees = 1 + rand(3)
    1.upto(num_extra_attendees) { |a|
      u.attendees << Factory(:attendee, :user_id => u.id, :is_player => true)
      }
    assert_equal num_extra_attendees + 1, u.attendees.size
    assert_equal (num_extra_attendees + 1) * 375, u.get_invoice_total
  end

  test "user (non-playing) with N non-playing attendees owes N * 75 dollars" do
    u = Factory(:user)
    u.primary_attendee.is_player = false
    u.save
    num_extra_attendees = 1 + rand(3)
    1.upto(num_extra_attendees) { |a|
      u.attendees << Factory(:attendee, :user_id => u.id, :is_player => false)
      }
    assert_equal num_extra_attendees + 1, u.attendees.size
    assert_equal (num_extra_attendees + 1) * 75, u.get_invoice_total
  end

  test "user (non-playing) with N players and M non-players owes N * 375 + M * 75 dollars" do
    u = Factory(:user)
    u.primary_attendee.is_player = false
    u.save
    num_players = 1 + rand(3)
    num_non_players = 1 + rand(3)
    1.upto(num_players) { |a|
      u.attendees << Factory(:attendee, :user_id => u.id, :is_player => true)
      }
    1.upto(num_non_players) { |a|
      u.attendees << Factory(:attendee, :user_id => u.id, :is_player => false)
      }
    assert_equal num_players + num_non_players + 1, u.attendees.size
    expected_cost = (num_non_players + 1) * 75 + (num_players * 375)
    assert_equal expected_cost, u.get_invoice_total
  end

  test "comp transaction" do
    u = Factory(:user)
    u.primary_attendee.is_player = true
    u.save
    assert_equal 375, u.get_invoice_total
    u.transactions << Factory(:tr_comp, :user_id => u.id, :amount => 33)
    u.transactions << Factory(:tr_comp, :user_id => u.id, :amount => 40)
    assert_equal 302, u.get_invoice_total
  end

  test "amount paid is sum of sale transactions" do
    u = Factory(:user)
    num_transactions = 10
    expected_sum = 0
    1.upto(num_transactions) { |n|
      t = Factory(:tr_sale, :user_id => u.id)
      expected_sum += t.amount
      u.transactions << t
      }
    assert_equal num_transactions, u.transactions.where(:trantype => 'S').length
    assert_equal expected_sum, u.amount_paid
  end

  test "balance" do
    u = Factory(:user)
    1.upto(1+rand(3)) { |a| u.attendees << Factory(:attendee, :user_id => u.id) }
    1.upto(1+rand(10)) { |n| u.transactions << Factory(:tr_sale, :user_id => u.id) }
    1.upto(1+rand(5)) { |n| u.transactions << Factory(:tr_comp, :user_id => u.id) }
    assert_equal u.get_invoice_total - u.amount_paid, u.balance
  end

  test "sum of invoice equals invoice total" do
    u = Factory(:user)
    1.upto(1+rand(3)) { |a| u.attendees << Factory(:attendee, :user_id => u.id) }
    expected_sum = 0
    u.get_invoice_items.each { |ii| expected_sum += ii['item_price'] }
    assert_equal expected_sum, u.get_invoice_total
  end

  test "destroying a user also destroys dependent attendees" do
    u = Factory(:user)
    num_extra_attendees = 1 + rand(3)
    1.upto(num_extra_attendees) { |a|
      u.attendees << Factory(:attendee, :user_id => u.id)
    }

    # when we destroy the user, we expect all dependent attendees
    # to be destroyed, including the primary_attendee
    expected_difference = -1 * (num_extra_attendees + 1)
    destroyed_user_id = u.id
    assert_difference 'Attendee.count', expected_difference do
      u.destroy
    end

    # double check
    assert_equal 0, Attendee.where(:user_id => destroyed_user_id).count
  end

  test "age-based discounts" do
    dc = Factory(:discount, :name => "Child", :amount => 150, :age_min => 0, :age_max => 12, :is_automatic => true)
    dy = Factory(:discount, :name => "Youth", :amount => 100, :age_min => 13, :age_max => 18, :is_automatic => true)
    u = Factory(:user)
    
    # 12 year old should get child discount and NOT youth discount
    a = Factory(:attendee, :birth_date => Time.utc(1998,9,10), :user_id => u.id, :understand_minor => true)
    assert_equal true, find_item_description?(u.get_invoice_items, dc.get_invoice_item_name)
    assert_equal false, find_item_description?(u.get_invoice_items, dy.get_invoice_item_name)

    # 11 year old should get child discount and NOT youth discount
    a.update_attribute :birth_date, Time.utc(1999,9,10)
    assert_equal 11, a.age_in_years.truncate
    u.reload
    assert_equal true, find_item_description?(u.get_invoice_items, dc.get_invoice_item_name)
    assert_equal false, find_item_description?(u.get_invoice_items, dy.get_invoice_item_name)

    # 13 year old should get YOUTH discount, not child discount
    a.update_attribute :birth_date, Time.utc(1997,9,10)
    assert_equal 13, a.age_in_years.truncate
    u.reload
    assert_equal false, find_item_description?(u.get_invoice_items, dc.get_invoice_item_name)
    assert_equal true, find_item_description?(u.get_invoice_items, dy.get_invoice_item_name)
  end

  test "plan with qty increases invoice total" do
    u = Factory(:user)
    u.attendees << Factory(:attendee, :user_id => u.id)
    total_before = u.get_invoice_total

    # add a plan with qty > 1 to attendee
    p = Factory :plan, :max_quantity => 10 + rand(10)
    qty = 1 + rand(p.max_quantity)
    ap = AttendeePlan.new :plan_id => p.id, :quantity => qty
    u.attendees.first.attendee_plans << ap

    # assert that user's inv. item total increases by price * qty
    expected = total_before + qty * p.price
    assert_equal expected.to_f, u.get_invoice_total.to_f

    # change plan qty by 1, assert that invoice total changes by price
    assert_difference('u.get_invoice_total.to_f', p.price) do
      ap.quantity += 1
    end
  end
  
  test "attendee cannot provide qty greater than plan max_qty" do
    u = Factory(:user)
    u.attendees << Factory(:attendee, :user_id => u.id)
    p = Factory :plan, :max_quantity => 1
    ap = AttendeePlan.new :plan_id => p.id, :quantity => p.max_quantity + 1
    assert_equal false, ap.valid?
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
