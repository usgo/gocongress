class Activity < ActiveRecord::Base
  include YearlyModel

  attr_accessible :activity_category_id, :name, :depart_time, :start, 
    :price, :notes, :return_depart_time, :return_arrive_time, :location

  # FIXME: in the controller, somehow year needs to get set 
  # before authorize! runs.  until then, year needs to be accessible.
  attr_accessible :year

  belongs_to :activity_category
  has_many :attendee_activities, :dependent => :destroy
  has_many :attendees, :through => :attendee_activities

  validates :activity_category, :presence => true
  validates_presence_of :start, :name
  validates_length_of :notes, :maximum => 250
  
  validates :location, :length => {:maximum => 50}
  validates :price, :numericality => { greater_than_or_equal_to: 0, allow_nil: true }
end
