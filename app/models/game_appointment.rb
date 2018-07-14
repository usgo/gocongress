class GameAppointment < ApplicationRecord
  include YearlyModel

  alias_attribute :white_player, :attendee_one
  alias_attribute :black_player, :attendee_two
  belongs_to :attendee_one, class_name: "Attendee",  foreign_key: "attendee_one_id"
  belongs_to :attendee_two, class_name: "Attendee",  foreign_key: "attendee_two_id"
  belongs_to :round

  validates :attendee_one, presence: true, uniqueness: { scope: :round,
    message: "players can only play in one game per round" }
  validates :attendee_two, presence: true, uniqueness: { scope: :round,
    message: "players can only play in one game per round" }

  validate :compare_attendees
  validates :round, presence: true
  validates :table, presence: true, uniqueness: { scope: :round, message: "a
    table can only have one game per round"}
  validates :location, presence: true
  validates :time, presence: true

  def compare_attendees
    if self.attendee_one == self.attendee_two
      errors.add("Attendees", "can't be the same person")
    end
  end

  def self.assign_from_hash(round, appointment)
    white = appointment['whitePlayer']
    black = appointment['blackPlayer']
    game_appointment = GameAppointment.new
    game_appointment.white_player = Attendee.find_by_aga_id(white['agaId'])
    game_appointment.black_player = Attendee.find_by_aga_id(black['agaId'])
    game_appointment.round = round
    game_appointment.table = appointment['tableNumber'].to_i
    game_appointment.time = round.start_time
    game_appointment.year = round.year
    game_appointment.result = appointment["result"]
    game_appointment.handicap = appointment["handicap"].to_i

    tournament = Tournament.find(round.tournament_id)
    game_appointment.location = tournament.location.empty? ? "N/A" : tournament.location

    game_appointment
  end

end
