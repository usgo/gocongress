class AttendeePlanDate < ActiveRecord::Base

  attr_accessible :_date

  belongs_to :attendee_plan

  validates :attendee_plan, presence: true
  validates :_date, presence: true, :timeliness => { :type => :date,
      :on_or_after => lambda {|d| minimum(d._date.year) },
      :on_or_before => lambda {|d| maximum(d._date.year) }
    }

  def self.maximum year
    y = year.is_a?(Year) ? year : Year.find_by_year(year.to_i)
    y.peak_departure_date + 1.day
  end

  def self.minimum year
    CONGRESS_START_DATE.fetch(year.to_i) - 2.days
  end

  def self.valid_range year
    (minimum(year)..maximum(year))
  end
end
