class Event < ActiveRecord::Base
  include YearlyModel

  attr_accessible :event_category_id, :name, :depart_time, :start, 
    :evtprice, :notes, :return_depart_time, :return_arrive_time, :location

  # FIXME: in the controller, somehow year needs to get set 
  # before authorize! runs.  until then, year needs to be accessible.
  attr_accessible :year

  belongs_to :event_category
  has_many :attendee_events, :dependent => :destroy
  has_many :attendees, :through => :attendee_events

  validates :event_category, :presence => true
  validates_presence_of :start, :name
  validates_length_of :notes, :maximum => 250
  
  validates :location, :length => {:maximum => 50}

  # Price should be numeric, but for some crazy reason, 
  # evtprice is a string.  Hence the ugly :unless blank? option
  validates_numericality_of :evtprice, \
    :greater_than_or_equal_to => 0, :allow_nil => true, \
    :unless => Proc.new { |e| e.evtprice.blank? }

end
