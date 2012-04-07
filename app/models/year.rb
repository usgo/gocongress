class Year < ActiveRecord::Base

  # Mass Assignment Security
  # ------------------------

  attr_accessible :city, :date_range, :day_off_date, :ordinal_number,
    :reply_to_email, :start_date, :state, :timezone, :twitter_url

  # Validations
  # -----------

  with_options({:presence => true}) do |wo|
    wo.validates :city
    wo.validates :date_range
    wo.validates :day_off_date
    wo.validates :ordinal_number, :numericality => { :only_integer => true, :minimum => 27 }
    wo.validates :registration_phase, :inclusion => { :in => %w(closed open complete) }
    wo.validates :reply_to_email
    wo.validates :start_date
    wo.validates :state
    wo.validates :timezone
    wo.validates :year, :numericality => { :only_integer => true, :minimum => 2011, :maximum => 2100 }
  end

  validates :twitter_url, :format => { :allow_nil => true, :with => /^https:\/{2}twitter.com/ }

  def nearby_airport_city
    year == 2012 ? "Asheville" : city
  end

  def peak_departure_date
    year == 2012 ? Date.civil(2012, 8, 12) : start_date + 8.days
  end
end
