class Event < ActiveRecord::Base
  attr_accessible :evtname, :evtdeparttime, :start, :evtprice, :notes, \
    :return_depart_time, :return_arrive_time, :location

  # FIXME: in the controller, somehow year needs to get set 
  # before authorize! runs.  until then, year needs to be accessible.
  attr_accessible :year

  has_many :attendee_events, :dependent => :destroy
  has_many :attendees, :through => :attendee_events

  validates_presence_of :start, :evtname, :year
  validates_length_of :notes, :maximum => 250
  validates_numericality_of :year, :only_integer => true, :greater_than => 2010, :less_than => 2100
  
  validates :location, :length => {:maximum => 50}

  # Price should be numeric, but for some crazy reason, 
  # evtprice is a string.  Hence the ugly :unless blank? option
  validates_numericality_of :evtprice, \
    :greater_than_or_equal_to => 0, :allow_nil => true, \
    :unless => Proc.new { |e| e.evtprice.blank? }

  # Scopes, and class methods that act like scopes
  def self.yr(year) where(:year => year) end

end
