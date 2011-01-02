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
  validates_inclusion_of :rank, :in => NUMERIC_RANK_LIST, :message => "is not a valid rank"
  validates_presence_of :email
  validates_presence_of :birth_date

  # Minors must agree to fill out the liability release form when they sign up
  # understand_minor is a database column, so we must specify accept => true
  # because the attribute is typecasted from "1" to true before validation.
  # -Jared 2011.1.2
  validates_acceptance_of :understand_minor, :on => :create, :accept => true

  # Alf, what does this mean? -Jared
  validates :understand_minor, :minor_agreement => true

	public
		def get_rank_name
			rank_name = ""
			RANKS.each { |r| if (r[1] == self.rank) then rank_name = r[0] end	}
			if rank_name.empty? then raise "assertion failed: invalid rank" end
			return rank_name
		end

end
