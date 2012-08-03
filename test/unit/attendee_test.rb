require 'test_helper'

class AttendeeTest < ActiveSupport::TestCase
  setup do
    @attendee = FactoryGirl.create :attendee
    @user = @attendee.user
  end

  test "#invoice_total" do
    # a user with no plans, discounts, activities, etc. should have a $0 total
    assert_equal 0, @attendee.invoice_total
  end

  test "#invoice_items" do
    # only discounts from the attendee's year should be included
    dc_2011 = FactoryGirl.create :discount_for_child, :year => 2011
    dc_now = FactoryGirl.create :discount_for_child
    a = FactoryGirl.create(:child, :user_id => @user.id)
    item_descriptions = a.invoice_items.map{|i| i.description}
    assert_equal true, item_descriptions.include?(dc_now.get_invoice_item_name)
    assert_equal false, item_descriptions.include?(dc_2011.get_invoice_item_name)
  end

  test "#minor?" do

    # The 2012 congress starts on 8/4, and John Doe will be 18
    john = FactoryGirl.build(:attendee, birth_date: Date.new(1994, 7, 5), year: 2012)
    assert !john.minor?

    # Jane Doe will be 17
    jane = FactoryGirl.build(:attendee, birth_date: Date.new(1994, 10, 1), year: 2012)
    assert jane.minor?
  end

  test "#birthday_after_congress" do
    jared = FactoryGirl.build(:attendee, birth_date: Date.new(1981, 9, 10), year: 2012)
    assert jared.birthday_after_congress

    john = FactoryGirl.build(:attendee, birth_date: Date.new(1990, 7, 5), year: 2012)
    assert !john.birthday_after_congress

    jane = FactoryGirl.build(:attendee, year: 2012)
    jane.birth_date = Date.new(2000, jane.congress_start.month, jane.congress_start.day)
    assert !jane.birthday_after_congress
  end

  test "#age_in_years" do

    # The 2012 congress starts on 8/4, and Arlene will be 41
    # Her birthday is after congress starts.
    arlene = FactoryGirl.build(:attendee, birth_date: Date.new(1970, 9, 22), year: 2012)
    assert_equal 41, arlene.age_in_years

    # John Doe's birthday is before congress starts.
    john = FactoryGirl.build(:attendee, birth_date: Date.new(1990, 7, 5), year: 2012)
    assert_equal 22, john.age_in_years
  end

  test "factory is valid" do
    assert FactoryGirl.build(:attendee).valid?
  end

  test "country must be two capital lettters" do
    assert_match( /^[A-Z]{2}$/, @attendee.country )
    update_success = @attendee.update_attributes( { :country => 'United States' } )
    assert !update_success
  end

  test "destroying an attendee also destroys dependent AttendeePlans" do
    a = FactoryGirl.create(:attendee, :user_id => @user.id)
    a.plans << FactoryGirl.create(:plan)

    # when we destroy the attendee, we expect all dependent AttendeePlans to be destroyed
    destroyed_attendee_id = a.id
    assert_difference('AttendeePlan.count', -1) do
      a.destroy
    end

    # double check
    assert_equal 0, AttendeePlan.where(:attendee_id => destroyed_attendee_id).count
  end

  test "early bird discount" do
    a = FactoryGirl.create(:attendee, {:created_at => Time.new(2011,1,2)})
    d = FactoryGirl.create(:discount, {:is_automatic => true, :min_reg_date => Time.new(2011,1,3)})
    assert attendee_has_discount(a,d), "min_reg_date should be satisfied with future date"

    d.update_column :min_reg_date, Time.new(2011,1,2)
    assert attendee_has_discount(a,d), "min_reg_date should be satisfied with matching date"

    d.update_column :min_reg_date, Time.new(2011,1,1)
    assert_equal false, attendee_has_discount(a,d), "min_reg_date should not be satisfied with past date"
  end

  def attendee_has_discount(a,d)
    invoice_item_names = a.invoice_items.map{|i| i.description}
    return invoice_item_names.index(d.get_invoice_item_name).present?
  end
end
