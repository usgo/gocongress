class GameAppointment < ApplicationRecord
  include YearlyModel

  alias_attribute :white_player, :attendee_one
  alias_attribute :black_player, :attendee_two

  belongs_to :attendee_one, class_name: "Attendee",  foreign_key: "attendee_one_id"
  belongs_to :attendee_two, class_name: "Attendee",  foreign_key: "attendee_two_id"
  belongs_to :round

  validates :attendee_one, presence: true
  validates :attendee_two, presence: true
  validates :round, presence: true
  validates :table, presence: true, uniqueness: { scope: :round, message: "a
    table can only have one game per round"}
  validates :location, presence: true
  validates :time, presence: true
  # Temporarily removed -- has performance issues
  # validate :attendees_play_one_game_per_round, unless: Proc.new { |a| a.round == nil }
  validate :compare_attendees

  def self.assign_from_hash(round, appointment)
    white = appointment['whitePlayer']
    black = appointment['blackPlayer']

    if (!white or !black)
      # If we weren't able to find the white or black player, don't keep trying
      # to create a game appointment.
      return
    end

    game_appointment = GameAppointment.new
    game_appointment.white_player = Attendee.current_year.find_by_aga_id(white['agaId'])
    game_appointment.black_player = Attendee.current_year.find_by_aga_id(black['agaId'])
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

  private

  def compare_attendees
    if self.attendee_one == self.attendee_two
      errors.add("Attendees", "can't be the same person")
    end
  end

  def attendees_play_one_game_per_round
    if self.round.game_appointments.any?
      self.round.game_appointments.find_each do |game|
        if self.attendee_one == game.attendee_one || self.attendee_one == game.attendee_two
          errors.add("Attendee", "#{self.attendee_one.full_name}(aga id:#{self.attendee_one.aga_id}) can only play one game per round")
        end
        if self.attendee_two == game.attendee_one || self.attendee_two == game.attendee_two
          errors.add("Attendee", "#{self.attendee_two.full_name}(aga id:#{self.attendee_two.aga_id}) can only play one game per round")
        end
      end
    end
  end

end
