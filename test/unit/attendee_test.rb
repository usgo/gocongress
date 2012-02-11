require 'test_helper'

class AttendeeTest < ActiveSupport::TestCase
  setup do
    @user = Factory :user
  end

  test "#invoice_total" do
    # a user with no plans, discounts, activities, etc. should have a $0 total
    assert_equal 0, @user.primary_attendee.invoice_total
  end

  test "#invoice_items" do
    # only discounts from the attendee's year should be included
    dc_2011 = Factory :discount_for_child, :year => 2011
    dc_now = Factory :discount_for_child
    birth_date = CONGRESS_START_DATE[Time.now.year] - 11.years
    a = Factory(:attendee_minor, :birth_date => birth_date, :user_id => @user.id)
    item_descriptions = a.invoice_items.map{|i| i.description}
    assert_equal true, item_descriptions.include?(dc_now.get_invoice_item_name)
    assert_equal false, item_descriptions.include?(dc_2011.get_invoice_item_name)
  end

  test "#minor?" do

    # The 2012 congress starts on 8/4, and John Doe will be 18
    john = Factory.build(:attendee, birth_date: Date.new(1994, 7, 5), year: 2012)
    assert !john.minor?

    # Jane Doe will be 17
    jane = Factory.build(:attendee, birth_date: Date.new(1994, 10, 1), year: 2012)
    assert jane.minor?
  end

  test "#birthday_after_congress" do
    jared = Factory.build(:attendee, birth_date: Date.new(1981, 9, 10), year: 2012)
    assert jared.birthday_after_congress

    john = Factory.build(:attendee, birth_date: Date.new(1990, 7, 5), year: 2012)
    assert !john.birthday_after_congress

    jane = Factory.build(:attendee, year: 2012)
    jane.birth_date = Date.new(2000, jane.congress_start.month, jane.congress_start.day)
    assert !jane.birthday_after_congress
  end

  test "#age_in_years" do

    # The 2012 congress starts on 8/4, and Arlene will be 41
    # Her birthday is after congress starts.
    arlene = Factory.build(:attendee, birth_date: Date.new(1970, 9, 22), year: 2012)
    assert_equal 41, arlene.age_in_years

    # John Doe's birthday is before congress starts.
    john = Factory.build(:attendee, birth_date: Date.new(1990, 7, 5), year: 2012)
    assert_equal 22, john.age_in_years
  end

  test "factory is valid" do
    assert Factory.build(:attendee).valid?
  end

  test "country must be two capital lettters" do
    assert_match( /^[A-Z]{2}$/, @user.primary_attendee.country )
    update_success = @user.primary_attendee.update_attributes( { :country => 'United States' } )
    assert !update_success
  end

  test "destroying an attendee also destroys dependent AttendeePlans" do
    a = Factory(:attendee, :user_id => @user.id)
    a.plans << Factory(:plan)

    # when we destroy the attendee, we expect all dependent AttendeePlans to be destroyed
    destroyed_attendee_id = a.id
    assert_difference('AttendeePlan.count', -1) do
      a.destroy
    end

    # double check
    assert_equal 0, AttendeePlan.where(:attendee_id => destroyed_attendee_id).count
  end

  test "early bird discount" do
    a = Factory(:attendee, {:created_at => Time.new(2011,1,2)})
    d = Factory(:discount, {:is_automatic => true, :min_reg_date => Time.new(2011,1,3)})
    assert attendee_has_discount(a,d), "min_reg_date should be satisfied with future date"

    d.update_attribute :min_reg_date, Time.new(2011,1,2)
    assert attendee_has_discount(a,d), "min_reg_date should be satisfied with matching date"

    d.update_attribute :min_reg_date, Time.new(2011,1,1)
    assert_equal false, attendee_has_discount(a,d), "min_reg_date should not be satisfied with past date"
  end

  def attendee_has_discount(a,d)
    invoice_item_names = a.invoice_items.map{|i| i.description}
    return invoice_item_names.index(d.get_invoice_item_name).present?
  end
end
