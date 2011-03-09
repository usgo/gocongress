require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "factory is valid" do
    assert Factory.build(:user).valid?
  end

  test "user (playing) with N go-playing attendees owes N * 375 dollars" do
    u = Factory(:user)
    u.primary_attendee.is_player = true
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

  test "amount paid is sum of transactions" do
    u = Factory(:user)
    num_transactions = 10
    expected_sum = 0
    1.upto(num_transactions) { |n|
      t = Factory(:transaction, :user_id => u.id)
      expected_sum += t.amount
      u.transactions << t
      }
    assert_equal num_transactions, u.transactions.where(:trantype => 'S').length
    assert_equal expected_sum, u.amount_paid
  end

  test "balance" do
    u = Factory(:user)
    1.upto(1+rand(3)) { |a| u.attendees << Factory(:attendee, :user_id => u.id) }
    1.upto(1+rand(10)) { |n| u.transactions << Factory(:transaction, :user_id => u.id) }
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

end
