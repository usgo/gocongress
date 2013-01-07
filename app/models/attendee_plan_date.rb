class AttendeePlanDate < ActiveRecord::Base
  belongs_to :attendee_plan
  validates :attendee_plan, presence: true
  validates :_date, presence: true, :timeliness => { :type => :date,
      :on_or_after => lambda {|d| d.minimum },
      :on_or_before => lambda {|d| d.maximum }
    }

  def maximum
    minimum + 2.weeks
  end

  def minimum
    CONGRESS_START_DATE[_date.year]
  end
end
