class Tournament < ActiveRecord::Base
  attr_protected :created_at, :updated_at, :year

  has_many :rounds, :dependent => :destroy
  has_many :attendee_tournaments, :dependent => :destroy
  has_many :attendees, :through => :attendee_tournaments

  accepts_nested_attributes_for :rounds, :allow_destroy => true

  # Openness Types:
  # Open - All attendees can sign up
  # Invitational - Admins select certain attendees
  OPENNESS_TYPES = [['Open','O'], ['Invitational','I']]

  validates_presence_of :name, :eligible, :description, :directors, :openness
  validates_length_of :openness, :is => 1
  validates_inclusion_of :openness, :in => OPENNESS_TYPES.flatten
  validates_numericality_of :year, :only_integer => true, :greater_than => 2010, :less_than => 2100

  validates :location, :length => {:maximum => 50}

  # Scopes, and class methods that act like scopes
  def self.openness(o) where(:openness => o) end
  def self.yr(year) where(:year => year) end

  def get_openness_type_name
    openness_name = ''
    OPENNESS_TYPES.each { |t| if (t[1] == self.openness) then openness_name = t[0] end }
    if openness_name.empty? then raise "assertion failed: invalid openness type" end
    return openness_name
  end
end
