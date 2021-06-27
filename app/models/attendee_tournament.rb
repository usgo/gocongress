class AttendeeTournament < ApplicationRecord
  include YearlyModel

  belongs_to :attendee
  belongs_to :tournament

  validates_presence_of :attendee, :tournament
  validates :year, :numericality => { :only_integer => true, :greater_than => 2010, :less_than => 2100 }

  before_validation do |attendee_tournament|
    if attendee_tournament.tournament.year != attendee_tournament.attendee.year
      raise "attendee and tournament have different years"
    end
    attendee_tournament.year ||= attendee_tournament.attendee.year
  end
end
