class AttendeeDiscount < ActiveRecord::Base
  belongs_to :attendee
  belongs_to :discount
  validates :year, :numericality => { :only_integer => true, :greater_than => 2010, :less_than => 2100 }

  before_validation do |ad|
    if ad.discount.year != ad.attendee.year
      raise "Attendee and Discount have different years"
    end
    ad.year ||= ad.attendee.year
  end
end
