class Attendee::Rank
  # Constant array of integer ranks and corresponding rank names
  # The highest official amateur dan rank in the AGA is 7 dan
  RANKS = []
  RANKS << ["Non-player", 0]
  109.downto(101).each { |r| RANKS << ["#{r - 100} pro", r] }
  7.downto(1).each { |r| RANKS << ["#{r} dan", r] }
  -1.downto(-30).each { |r| RANKS << ["#{-r} kyu", r] }

  # Constant array of integer ranks
  NUMERIC_RANK_LIST = []
  RANKS.each { |r| NUMERIC_RANK_LIST << r[1] }

  def initialize(n)
    @n = n
  end

  def name
    pair = RANKS.find { |r| r[1] == @n }
    pair ? pair[0] : raise("Invalid rank: #{@n}")
  end

  def pro?
    (101..109).include?(@n)
  end

  def dan?
    (1..9).include?(@n)
  end

  def kyu?
    (-30..-1).include?(@n)
  end
end
