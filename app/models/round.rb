class Round < ApplicationRecord
  belongs_to :tournament

  validates :number, presence: true
  validates :start_time, presence: true
end
