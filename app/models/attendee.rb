class Attendee < ActiveRecord::Base
  belongs_to :user

  # define constant array of rank hashes {integer rank, rank name}
  RANKS = []
  RANKS << [ "Non-player", 0]
  109.downto(101).each {|r| RANKS << ["#{r-100} pro", r] }
  8.downto(1).each {|r| RANKS << [ "#{r} dan", r] }
  -1.downto(-30).each {|r| RANKS << ["#{-r} kyu", r] }

  # define constant array of integer ranks
  NUMERIC_RANK_LIST = []
  Attendee::RANKS.each { |r| NUMERIC_RANK_LIST << r[1] }

  # TODO: Add Validation for gender
  
  validates_presence_of :rank
  validates_inclusion_of :rank, :in => NUMERIC_RANK_LIST
  validates_presence_of :email
  validates_presence_of :birth_date
  validates :understand_minor, :minor_agreement => true

end
