require 'test_helper'

class AttendeeTest < ActiveSupport::TestCase
  setup do
    @attendee = create :attendee
    @user = @attendee.user
  end

  test "#age_in_years" do

    # The 2012 congress starts on 8/4, and Arlene will be 41
    # Her birthday is after congress starts.
    arlene = build(:attendee, birth_date: Date.new(1970, 9, 22), year: 2012)
    assert_equal 41, arlene.age_in_years

    # John Doe's birthday is before congress starts.
    john = build(:attendee, birth_date: Date.new(1990, 7, 5), year: 2012)
    assert_equal 22, john.age_in_years
  end

  test "factory is valid" do
    assert build(:attendee).valid?
  end

  test "country must be two capital lettters" do
    assert_match( /^[A-Z]{2}$/, @attendee.country )
    update_success = @attendee.update_attributes( { :country => 'United States' } )
    assert !update_success
  end

  test "destroying an attendee also destroys dependent AttendeePlans" do
    a = create(:attendee, :user_id => @user.id)
    a.plans << create(:plan)

    # when we destroy the attendee, we expect all dependent AttendeePlans to be destroyed
    destroyed_attendee_id = a.id
    assert_difference('AttendeePlan.count', -1) do
      a.destroy
    end

    # double check
    assert_equal 0, AttendeePlan.where(:attendee_id => destroyed_attendee_id).count
  end

  test "early bird discount" do
    a = create(:attendee, {:created_at => Time.new(2011,1,2)})
    d = create(:discount, {:is_automatic => true, :min_reg_date => Time.new(2011,1,3)})
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
