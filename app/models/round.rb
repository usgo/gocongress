class Round < ApplicationRecord
  include YearlyModel

  belongs_to :tournament

  validates :number, presence: true
  validates :start_time, presence: true
end
