class Round < ActiveRecord::Base
  attr_accessible :round_start
  attr_protected :created_at, :updated_at, :tournament_id
  belongs_to :tournament
end
