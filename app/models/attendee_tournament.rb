class AttendeeTournament < ActiveRecord::Base
  belongs_to :attendee
  belongs_to :tournament
  validates_presence_of :attendee, :tournament
end
