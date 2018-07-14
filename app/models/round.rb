class Round < ApplicationRecord
  include YearlyModel

  belongs_to :tournament
  has_many :game_appointments, -> { order(:table) }, dependent: :destroy
  validates :number, presence: true
  validates :number, uniqueness: { scope: :tournament_id, message: "A round with that number already exists for the tournament."}
  validates :start_time, presence: true
end
