class Activity < ActiveRecord::Base
  include YearlyModel
  include Purchasable

  attr_accessible :activity_category_id, :leave_time, :name, :notes,
    :price, :return_time, :location

  # FIXME: in the controller, somehow year needs to get set
  # before authorize! runs.  until then, year needs to be accessible.
  attr_accessible :year

  belongs_to :activity_category
  has_many :attendee_activities, :dependent => :destroy
  has_many :attendees, :through => :attendee_activities

  validates :activity_category, :presence => true
  validates_presence_of :leave_time, :name, :return_time
  validates_length_of :notes, :maximum => 250

  validates :location, :length => {:maximum => 50}
end
