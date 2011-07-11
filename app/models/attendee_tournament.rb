class AttendeeTournament < ActiveRecord::Base
  belongs_to :attendee
  belongs_to :tournament
  validates_presence_of :attendee, :tournament
  validates_length_of :notes, :maximum => 50

  def self.tmt_names_by_attendee
    attendee_tournaments = Hash.new
    AttendeeTournament.includes(:tournament).order(:attendee_id).each do |at|
      if at.tournament.present? then
        if attendee_tournaments[at.attendee_id].nil?
          attendee_tournaments[at.attendee_id] = Array.new
        end
        attendee_tournaments[at.attendee_id].push(at.tournament.name)
      end
    end
    return attendee_tournaments
  end

end
