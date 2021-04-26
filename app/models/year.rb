class Year < ApplicationRecord
  after_initialize :init

  enum event_type: [:'in-person', :online]

  REG_PHASES = %w[closed open complete canceled]

  # Validations
  # -----------

  with_options({:presence => true}) do |wo|
    wo.validates :event_type
    wo.validates :city, unless: :is_online?
    wo.validates :date_range
    wo.validates :day_off_date
    wo.validates :ordinal_number, :numericality => { :only_integer => true, :minimum => 27 }
    wo.validates :registration_phase, :inclusion => { :in => %w(closed open complete canceled) }
    wo.validates :reply_to_email
    wo.validates :start_date
    wo.validates :state, unless: :is_online?
    wo.validates :timezone
    wo.validates :year, :numericality => { :only_integer => true, :minimum => 2011, :maximum => 2100 }
  end

  validates :twitter_url, :format => { :allow_blank => true, :with => /\Ahttps:\/{2}twitter.com/ }

  def init
    # Set default values
    self.event_type ||=:'in-person'
  end

  def is_online?
    event_type == :online.to_s
  end

  def circular_logo?
    year != 2013 # they have a rectangular logo
  end

  def facebook_url
    if year == 2012
      "https://www.facebook.com/pages/2012-US-Go-Congress/278646688879639"
    elsif year == 2011
      "https://www.facebook.com/pages/2011-US-Go-Congress/191063107571864"
    end
  end

  def nearby_airport_city
    year == 2012 ? "Asheville" : city
  end

  # `peak_departure_date` is used for travel plans, and in the valid
  # range of dates for daily-rate plans.  It never returns nil.
  def peak_departure_date
    year == 2012 ? Date.civil(2012, 8, 12) : start_date + 8.days
  end

  def sponsors
    s = sponsors_by_year[self.year]
    s = [:aga] if s.nil?

    all_sponsors.reject{|k,v| !s.include?(k)}
  end

  def to_i() year end

  def to_s
    self.year.to_s
  end

private

  def all_sponsors
    {
      :aga => "http://www.usgo.org",
      :agf => "http://agfgo.org",
      :confucius => "http://oia.ncsu.edu/confucius",
      :jpga => "http://www.pairgo.or.jp",
      :kaba => "http://www.kbaduk.or.kr/eng/",
      :kgs => "http://www.gokgs.com",
      :pandanet => "http://www.pandanet-igs.com",
      :slate_and_shell => "http://www.slateandshell.com",
      :tygem => "http://www.tygembaduk.com"
    }
  end

  def sponsors_by_year
    {
      2011 => [:aga, :kaba, :kgs],
      2012 => [:aga, :agf, :confucius, :jpga, :kaba, :pandanet, :slate_and_shell, :tygem],
      2020 => [:aga, :agf]
    }
  end

end
