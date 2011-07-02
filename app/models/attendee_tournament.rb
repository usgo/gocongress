class AttendeeTournament < ActiveRecord::Base
  belongs_to :attendee
  belongs_to :tournament
  validates_presence_of :attendee, :tournament
  validates_length_of :notes, :maximum => 50
end
