class Attendee < ActiveRecord::Base
  belongs_to :user

  AGE_DEADLINE = "July 29, 2011"
    
  # to do: use attr_protected

  # define constant array of rank hashes {integer rank, rank name}
  RANKS = []
  RANKS << [ "Non-player", 0]
  109.downto(101).each {|r| RANKS << ["#{r-100} pro", r] }
  8.downto(1).each {|r| RANKS << [ "#{r} dan", r] }
  -1.downto(-30).each {|r| RANKS << ["#{-r} kyu", r] }

  # define constant array of integer ranks
  NUMERIC_RANK_LIST = []
  Attendee::RANKS.each { |r| NUMERIC_RANK_LIST << r[1] }

  validates_presence_of :gender
  validates_inclusion_of :gender, :in => ["m","f"], :message => "is not valid"
  validates_inclusion_of :is_primary, :in => [true, false]
  validates_uniqueness_of :aga_id, :allow_nil => true
  validates_presence_of :address_1, :birth_date, :city,  :country, :email, :family_name, :given_name, :rank
  validates_inclusion_of :rank, :in => NUMERIC_RANK_LIST, :message => "is not a valid rank"
  
  # Attendees must belong to a user (except when they are first being created,      
  # because in a nested form there might not be a user_id yet.  I think that is what
  # is going on, anyway) I'm surprised this is necessary at all, and I'm unsettled  
  # by the lack of a foreign key constraint. -Jared 2011.1.2
  validates_presence_of :user_id, :on => :update

  # Use MinorAgreementValidator (found in lib/) to require that understand_minor
  # be checked if the attendee will not be 18 before the first day of the Congress.
  validates :understand_minor, :minor_agreement => true
  
  # to do: validate that each user has exactly one primary attendee

  # only apply these validations on the baduk form page ("player info")
  with_options :on => :update, :if => :form_page_is_baduk? do |baduk_page_options|
    baduk_page_options.validates_numericality_of :congresses_attended
    baduk_page_options.validates_inclusion_of :is_player, :in => [true, false]
    baduk_page_options.validates_inclusion_of :will_play_in_us_open, :in => [true, false]
    baduk_page_options.validates_inclusion_of :is_current_aga_member, :in => [true, false]
  end

  def form_page_is_baduk?
    @form_page == :baduk
  end

  def form_page_is_basics?
    @form_page == :basics
  end

  # is the model valid for a given form page? -Jared
  def valid_in_form_page?(form_page)
    @form_page = form_page
    valid?
  end

  def is_minor
    deadline = Date.strptime(AGE_DEADLINE, "%B %d, %Y")
    return (self.birth_date + 18.years > deadline)
  end

  def get_full_name
    given_name + " " + family_name
  end

  def get_rank_name
    rank_name = ""
    RANKS.each { |r| if (r[1] == self.rank) then rank_name = r[0] end }
    if rank_name.empty? then raise "assertion failed: invalid rank" end
    return rank_name
  end
end
