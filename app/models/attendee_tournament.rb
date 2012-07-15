class AttendeeTournament < ActiveRecord::Base
  include YearlyModel

  belongs_to :attendee
  belongs_to :tournament

  # As with other attendee linking tables, mass-assignment security
  # is not necessary yet, but may be in the future.  See the more
  # detailed discussion in `attendee_activity.rb` -Jared 2012-07-15
  attr_accessible :attendee_id, :tournament_id, :notes

  validates_presence_of :attendee, :tournament
  validates_length_of :notes, :maximum => 50

  before_validation do |at|
    if at.tournament.year != at.attendee.year
      raise "Attendee and Tournament have different years"
    end
    at.year ||= at.attendee.year
  end

  def self.tmt_names_by_attendee(year)
    attendee_tournaments = Hash.new
    AttendeeTournament.yr(year).includes(:tournament).order(:attendee_id).each do |at|
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
