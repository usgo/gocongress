class GameAppointment < ApplicationRecord
  include YearlyModel

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
    game_appointment.attendee_one = Attendee.find_by_aga_id(white['agaId'])
    game_appointment.attendee_two = Attendee.find_by_aga_id(black['agaId'])
    game_appointment.round = round
    game_appointment.table = appointment['tableNumber'].to_i
    game_appointment.time = round.start_time
    game_appointment.year = round.year

    tournament = Tournament.find(round.tournament_id)
    game_appointment.location = tournament.location

    game_appointment
  end

  # after_create :notification

  # Notify our appointment attendee X minutes before the appointment time
  def notification
    @twilio_number = ENV['TWILIO_NUMBER']
    account_sid = ENV['TWILIO_ACCOUNT_SID']
    @client = Twilio::REST::Client.new account_sid, ENV['TWILIO_AUTH_TOKEN']
    time_str = ((self.time).localtime).strftime("%I:%M%p on %b. %d, %Y")
<<<<<<< HEAD
    notification = "Hi #{self.attendee}. You have a game scheduled with the following details: Opponent: #{self.oppoenent}, Time: #{time_str}, Location: #{self.location}."
    message = @client.api.account(account_sid).messages.create(
      :from => @twilio_number,
      :to => self.attendee.phone_number,
      :body => notification,
=======
    reminder = "Hi #{self.attendee}. You have a game scheduled with the following details: Opponent: #{self.oppoenent}, Time: #{time_str}, Location: #{self.location}."
    message = @client.api.account(account_sid).messages.create(
      :from => @twilio_number,
      :to => self.attendee.phone_number,
      :body => reminder,
>>>>>>> Added Game Appointments
    )
  end
end
