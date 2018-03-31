class AttendeePlanDate < ApplicationRecord

  belongs_to :attendee_plan

  validates :attendee_plan, presence: true
  validates :_date, presence: true, :timeliness => { :type => :date,
      :on_or_after => lambda {|d| minimum(d._date.year) },
      :on_or_before => lambda {|d| maximum(d._date.year) }
    }

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
end
