class Round < ApplicationRecord
  include YearlyModel

  belongs_to :tournament
  has_many :game_appointments, dependent: :destroy
  validates :number, presence: true
  validates :start_time, presence: true
end
