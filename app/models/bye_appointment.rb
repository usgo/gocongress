class ByeAppointment < ApplicationRecord
  belongs_to :round
  belongs_to :attendee

  def self.assign_from_hash round, bye
    player = bye[:attendee]
    bye_appointment = ByeAppointment.new
    bye_appointment.round = round
    bye_appointment.attendee = Attendee.find_by_aga_id(player["agaId"])
    bye_appointment
  end
end
