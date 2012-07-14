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

  def peak_departure_date
    year == 2012 ? Date.civil(2012, 8, 12) : start_date + 8.days
  end

  def sponsors
    s = sponsors_by_year[self.year]
    all_sponsors.reject{|k,v| !s.include?(k)}
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
      2012 => [:aga, :agf, :confucius, :jpga, :kaba, :pandanet, :slate_and_shell, :tygem]
    }
  end

end
