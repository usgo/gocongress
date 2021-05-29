# For "daily" plans, which dates did the attendee select? For example, airport
# shuttle, but only on arrival.
class AttendeePlanDate < ApplicationRecord
  belongs_to :attendee_plan

  validates :attendee_plan, presence: true

  # This database column probably has a leading underscore to distinguish
  # it from the `date` data type. Makes sense, but looks a bit awkward in
  # ruby. Maybe rename to something like `ap_date`?
  validates :_date, presence: true
  validate :check_date_range

  def self.maximum year
    y = year.is_a?(Year) ? year : Year.find_by_year(year.to_i)
    if y.to_i >= 2015
      y.peak_departure_date - 1.day
    else
      y.peak_departure_date + 1.day
    end
  end

  def self.minimum year
    if year.to_i >= 2015
      CONGRESS_START_DATE.fetch(year.to_i)
    else
      CONGRESS_START_DATE.fetch(year.to_i) - 2.days
    end
  end

  def self.valid_range year
    (minimum(year)..maximum(year))
  end

  private

  def check_date_range
    return if _date.blank?
    year = _date.year
    min = self.class.minimum(year)
    max = self.class.maximum(year)
    unless (min..max).cover?(_date)
      errors.add(:_date, format('must be between %s and %s (inclusive)', min, max))
    end
  end
end
