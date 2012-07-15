class Round < ActiveRecord::Base
  belongs_to :tournament
  attr_accessible :round_start
  validates_date :round_start, :after => Date.civil(2011, 1, 1)
end
