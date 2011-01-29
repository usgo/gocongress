class Preregistrant < ActiveRecord::Base

  validates_inclusion_of :anonymous, :in => [true, false]
  validates_inclusion_of :ranktype, :in => %w[k d p]

  def get_rank_name
    ranktypes = { 'k' => 'kyu', 'd' => 'dan', 'p' => 'pro' }
    if ranktype == 'np' || rank == 0
      return 'Non-player'
    end
    return rank.to_s + ' ' + ranktypes[self.ranktype]
  end

end
