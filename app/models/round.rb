class Round < ActiveRecord::Base
  attr_accessible :round_start
  attr_protected :created_at, :updated_at, :tournament_id
  belongs_to :tournament
  validates_date :round_start, :after => Date.civil(2011, 1, 1)
end
