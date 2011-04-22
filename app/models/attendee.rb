class Attendee < ActiveRecord::Base
  belongs_to :user

  has_many :attendee_plans, :dependent => :destroy
  has_many :plans, :through => :attendee_plans

  has_many :attendee_discounts, :dependent => :destroy
  has_many :discounts, :through => :attendee_discounts

  AGE_DEADLINE = "July 29, 2011"

  # Mass assignment config
  attr_accessible :given_name, :family_name, :gender, :anonymous, :rank, :aga_id, \
    :address_1, :address_2, :city, :state, :zip, :country, :phone, :email, :birth_date, \
    :understand_minor, :congresses_attended, :is_player, :will_play_in_us_open, \
    :is_current_aga_member, :tshirt_size, :special_request, :roomate_request

  # define constant array of ranks
  RANKS = []
  RANKS << [ "Non-player", 0]
  109.downto(101).each {|r| RANKS << ["#{r-100} pro", r] }
  8.downto(1).each {|r| RANKS << [ "#{r} dan", r] }
  -1.downto(-30).each {|r| RANKS << ["#{-r} kyu", r] }

  # define constant array of integer ranks
  NUMERIC_RANK_LIST = []
  Attendee::RANKS.each { |r| NUMERIC_RANK_LIST << r[1] }
  
  # tshirt sizes
  TSHIRT_CHOICES = []
  TSHIRT_CHOICES << ["None",            "NO"]
  TSHIRT_CHOICES << ["Youth Medium",    "YM"]
  TSHIRT_CHOICES << ["Youth Large",     "YL"]
  TSHIRT_CHOICES << ["Adult Small",     "AS"]
  TSHIRT_CHOICES << ["Adult Medium",    "AM"]
  TSHIRT_CHOICES << ["Adult Large",     "AL"]
  TSHIRT_CHOICES << ["Adult X-Large",   "1X"]
  TSHIRT_CHOICES << ["Adult XX-Large",  "2X"]
  TSHIRT_CHOICES << ["Adult XXX-Large", "3X"]

  # define constant array of tshirt sizes
  TSHIRT_SIZE_LIST = []
  Attendee::TSHIRT_CHOICES.each { |t| TSHIRT_SIZE_LIST << t[1] }

  # Some "blank" birth_date values have made it into production. The following
  # scope is a useful way to filter out those records when querying birth_date
  # (eg. finding youngest attendee) -Jared 2011-02-07
  scope :reasonable_birth_date, where("birth_date > ? AND birth_date < ?", '1880-01-01', Time.now())

  # Begin validations
  validates_format_of :country, :with => /^[A-Z]{2}$/, :message => "must be exactly two capital letters"
  validates_format_of :zip, :allow_blank => true, :with => /^\d{5}(-\d{4})?$/, :if => :country_is_america?, :message => "is not valid for the selected country"
  validates_presence_of :gender
  validates_inclusion_of :gender, :in => ["m","f"], :message => "is not valid"
  validates_inclusion_of :is_primary, :in => [true, false]
  validates_uniqueness_of :aga_id, :allow_nil => true
  validates_presence_of :address_1, :birth_date, :city,  :country, :email, :family_name, :given_name, :rank
  validates_inclusion_of :rank, :in => NUMERIC_RANK_LIST, :message => "is not a valid rank"
  validates_inclusion_of :tshirt_size, :in => TSHIRT_SIZE_LIST, :message => "is not valid"
  validates_length_of :special_request, :maximum => 250
  validates_length_of :roomate_request, :maximum => 250
  validates_date :birth_date, :after => Date.civil(1900,1,1), :allow_blank => false
  
  # Attendees must belong to a user (except when they are first being created,      
  # because in a nested form there might not be a user_id yet.  I think that is what
  # is going on, anyway) I'm surprised this is necessary at all, and I'm unsettled  
  # by the lack of a foreign key constraint. -Jared 2011.1.2
  validates_presence_of :user_id, :on => :update

  # Use MinorAgreementValidator (found in lib/) to require that understand_minor
  # be checked if the attendee will not be 18 before the first day of the Congress.
  validates :understand_minor, :minor_agreement => true
  
  # Validate that each user has exactly one primary attendee -Jared
  validates_uniqueness_of :is_primary, :scope => :user_id, :if => :is_primary?

  # only apply these validations on the baduk form page ("player info")
  with_options :on => :update, :if => :form_page_is_baduk? do |b|
    b.validates_numericality_of :congresses_attended, :greater_than_or_equal_to => 0
    b.validates_inclusion_of :is_player, :in => [true, false]
    b.validates_inclusion_of :will_play_in_us_open, :in => [true, false]
    b.validates_inclusion_of :is_current_aga_member, :in => [true, false]
  end
  
  # validations for admin page
  validates_date :deposit_received_at, :if => :form_page_is_admin?, :allow_blank => true

  def age_in_seconds
    # age on the start day of the event, not now
    (CONGRESS_START_DATE - self.birth_date.to_time).to_i
  end
  
  def age_in_years
    self.age_in_seconds / 60.0 / 60.0 / 24.0 / 365.0
  end

  def country_is_america?
    self.country == 'US'
  end

  def form_page_is_baduk?
    @form_page == :baduk
  end

  def form_page_is_admin?
    @form_page == :admin
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

  def full_name_possessive
    given_name + " " + family_name + ('s' == family_name[-1,1] ? "'" : "'s")
  end

  def possessive_pronoun_or_name
    is_primary? ? "My" : full_name_possessive
  end
  
  def objective_pronoun_or_name_and_copula
    is_primary? ? "You are" : get_full_name + " is"
  end

  def get_rank_name
    rank_name = ""
    RANKS.each { |r| if (r[1] == self.rank) then rank_name = r[0] end }
    if rank_name.empty? then raise "assertion failed: invalid rank" end
    return rank_name
  end

  def get_registration_price
    self.is_player? ? 375 : 75
  end

end
