require "invoice_item"

class Attendee < ActiveRecord::Base
  belongs_to :user

  has_many :attendee_plans, :dependent => :destroy
  has_many :plans, :through => :attendee_plans

  has_many :attendee_discounts, :dependent => :destroy
  has_many :discounts, :through => :attendee_discounts

  has_many :attendee_tournaments, :dependent => :destroy
  has_many :tournaments, :through => :attendee_tournaments

  has_many :attendee_events, :dependent => :destroy
  has_many :events, :through => :attendee_events

  AGE_DEADLINE = "July 29, 2011"

  # Mass assignment config
  attr_accessible :given_name, :family_name, :gender, :anonymous, :rank, :aga_id, \
    :address_1, :address_2, :city, :state, :zip, :country, :phone, :email, :birth_date, \
    :understand_minor, :congresses_attended, :is_player, :will_play_in_us_open, \
    :is_current_aga_member, :tshirt_size, :special_request, :roomate_request

  # Define constant array of integer ranks and corresponding rank names
  # The highest official amateur dan rank in the AGA is 7 dan
  RANKS = []
  RANKS << [ "Non-player", 0]
  109.downto(101).each {|r| RANKS << ["#{r-100} pro", r] }
  7.downto(1).each {|r| RANKS << [ "#{r} dan", r] }
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
  validates_inclusion_of :minor_agreement_received, :in => [true, false]
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

  def self.registration_price(registration_type)
    unless %w[player nonplayer].include?(registration_type.to_s) then
      raise 'Invalid registration_type: ' + registration_type.to_s
    end
    registration_type.to_s == 'player' ? 375 : 75
  end

  def age_in_seconds
    # age on the start day of the event, not now
    (CONGRESS_START_DATE - self.birth_date.to_time).to_i
  end
  
  def age_in_years
    self.age_in_seconds / 60.0 / 60.0 / 24.0 / 365.0
  end

  def attribute_names_for_csv
    
    # do not export ids
    no_export_attrs = %w[id user_id]
    
    # Lisa says:
    # put the name and email in the first few columns
    # group together address, city, state, etc.
    first_attrs = %w[aga_id family_name given_name address_1 address_2 city state zip country phone]
    
    # we should move roommate request next to the plans
    last_attrs = %w[special_request roomate_request]

    attrs = self.attribute_names.delete_if { |x| 
      first_attrs.index(x) ||
      last_attrs.index(x) ||
      no_export_attrs.index(x)
    }

    # note: the order must match attendee_to_array() in reports_helper.rb
    return first_attrs.concat(attrs.concat(last_attrs))
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

  def invoice_items
    invoice_items = []
    
    # registration fee for each attendee
    reg_desc = "Registration " + (self.is_player? ? "(Player)" : "(Non-Player)")
    invoice_items.push InvoiceItem.inv_item_hash( reg_desc, self.get_full_name, self.get_registration_price, 1 )

    # How old will the attendee be on the first day of the event?
    # Also, truncate to an integer age to simplify logic below
    atnd_age = self.age_in_years.truncate

    # Does this attendee qualify for any automatic discounts?
    Discount.where("is_automatic = ?", true).each do |d|

      # Currently, we only apply age-related automatic discounts.
      # In the future, there will also be "early bird" discounts,
      # but we haven't figured out the details yet.
      satisfy_age_min = d.age_min.blank? || atnd_age >= d.age_min
      satisfy_age_max = d.age_max.blank? || atnd_age <= d.age_max
      if (satisfy_age_min && satisfy_age_max) then
        invoice_items.push InvoiceItem.inv_item_hash(d.get_invoice_item_name, self.get_full_name, -1 * d.amount, 1)
      end
    end

    # Did this attendee claim any non-automatic discounts?
    self.discounts.where("is_automatic = ?", false).each do |d|
      invoice_items.push InvoiceItem.inv_item_hash(d.get_invoice_item_name, self.get_full_name, -1 * d.amount, 1)
    end

    # room and board invoice items
    self.attendee_plans.each do |ap|
      p = ap.plan
      invoice_items.push InvoiceItem.inv_item_hash('Plan: ' + p.name, self.get_full_name, p.price, ap.quantity)
    end
    
    # Events
    self.events.each do |e|
      if e.evtprice.to_f > 0.0 then
        invoice_items.push InvoiceItem.inv_item_hash('Event: ' + e.evtname, self.get_full_name, e.evtprice.to_f, 1)
      end
    end
    
    return invoice_items
  end

  def invoice_total
    InvoiceItem.inv_item_total(self.invoice_items)
  end

  def is_minor
    deadline = Date.strptime(AGE_DEADLINE, "%B %d, %Y")
    return (self.birth_date + 18.years > deadline)
  end

  def get_full_name(respect_anonymity = false)
    (anonymous? && respect_anonymity) ? 'Anonymous' : given_name + " " + family_name
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

  def get_plan_qty(plan_id)
    ap = self.attendee_plans.where(:plan_id => plan_id).first
    return ap.present? ? ap.quantity : 0
  end

  def get_rank_name
    rank_name = ""
    RANKS.each { |r| if (r[1] == self.rank) then rank_name = r[0] end }
    if rank_name.empty? then raise "assertion failed: invalid rank" end
    return rank_name
  end

  def get_registration_price
    reg_type = self.is_player? ? :player : :nonplayer
    Attendee.registration_price reg_type
  end

  def get_tshirt_size_name
    tshirt_size_name = nil
    TSHIRT_CHOICES.each { |t| if (t[1] == self.tshirt_size) then tshirt_size_name = t[0] end }
    if tshirt_size_name.nil? then raise "assertion failed: invalid tshirt_size" end
    return tshirt_size_name
  end

  def get_notes_for_tournament(tid)
    at = self.attendee_tournaments.find_by_tournament_id(tid)
    at.present? ? at.notes : ''
  end
end
