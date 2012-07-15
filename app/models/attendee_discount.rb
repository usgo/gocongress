class AttendeeDiscount < ActiveRecord::Base
  belongs_to :attendee
  belongs_to :discount

  # As with other attendee linking tables, mass-assignment security
  # is not necessary yet, but may be in the future.  See the more
  # detailed discussion in `attendee_activity.rb` -Jared 2012-07-15
  attr_accessible :attendee_id, :discount_id

  validates :year, :numericality => { :only_integer => true, :greater_than => 2010, :less_than => 2100 }

  before_validation do |ad|
    if ad.discount.year != ad.attendee.year
      raise "Attendee and Discount have different years"
    end
    ad.year ||= ad.attendee.year
  end
end
