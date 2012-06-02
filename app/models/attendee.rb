require "invoice_item"

class Attendee < ActiveRecord::Base
  include YearlyModel

  belongs_to :user

  has_many :attendee_plans, :dependent => :destroy
  has_many :plans, :through => :attendee_plans

  has_many :attendee_discounts, :dependent => :destroy
  has_many :discounts, :through => :attendee_discounts

  has_many :attendee_tournaments, :dependent => :destroy
  has_many :tournaments, :through => :attendee_tournaments

  has_many :attendee_activities, :dependent => :destroy
  has_many :activities, :through => :attendee_activities

  # Mass assignment config
  attr_accessible :address_1, :address_2, :aga_id, :anonymous,
    :airport_arrival, :airport_arrival_flight, :airport_departure,
    :birth_date, :city, :congresses_attended, :country, :email,
    :family_name, :flying, :given_name, :gender,
    :guardian_full_name, :phone, :special_request,
    :state, :rank, :roomate_request, :tshirt_size,
    :understand_minor, :zip

  # FIXME: in the controller, somehow year needs to get set
  # before authorize! runs.  until then, year needs to be accessible.
  attr_accessible :year

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
  TSHIRT_CHOICES << ["Youth Small",     "YS"]
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

  # Scopes
  # ------

  # Some "blank" birth_date values have made it into production. The following
  # scope is a useful way to filter out those records when querying birth_date
  # (eg. finding youngest attendee) -Jared 2011-02-07
  scope :reasonable_birth_date, where("birth_date > ? AND birth_date < ?", '1880-01-01', Time.now())

  # Using a subquery in the where clause is performant up to about
  # one thousand records.  -Jared 2012-05-13
  scope :with_at_least_one_plan, where("0 < (select count(*) from attendee_plans ap where ap.attendee_id = attendees.id)")
  scope :planless, where("0 = (select count(*) from attendee_plans ap where ap.attendee_id = attendees.id)")

  # Validations
  # -----------

  validates :country, :format => {:with => /^[A-Z]{2}$/}, :presence => true

  validates :flying, :inclusion => { :in => [true, false] }
  validates_each :flying do |model, attr, value|
    no_arrival = model.airport_arrival.blank?
    no_departure = model.airport_departure.blank?
    if value && no_arrival && no_departure then
      model.errors.add("If you want help with the airport shuttle",
        " please tell us when you'll be arriving or departing")
    end
  end

  validates_presence_of :gender
  validates_inclusion_of :gender, :in => ["m","f"], :message => "is not valid"
  validates :guardian_full_name, :presence => { :if => :require_guardian_full_name? }
  validates_inclusion_of :is_primary, :in => [true, false]
  validates_inclusion_of :minor_agreement_received, :in => [true, false]
  validates_presence_of :address_1, :birth_date, :city, :email, :family_name, :given_name, :rank
  validates_inclusion_of :rank, :in => NUMERIC_RANK_LIST, :message => "is not a valid rank"
  validates_inclusion_of :tshirt_size, :in => TSHIRT_SIZE_LIST, :message => " - Please select a size"
  validates_length_of :special_request, :maximum => 250
  validates_length_of :roomate_request, :maximum => 250
  validates_date :birth_date, :after => Date.civil(1900,1,1), :allow_blank => false
  validates :congresses_attended, :numericality => {:greater_than_or_equal_to => 0, :only_integer => true, :allow_nil => true}

  validates :state,
    :presence => true,
    :format => {
      :with => /^[A-Z]{2}$/,
      :if => :country_is_america?,
      :message => " - Please use two-letter abbreviations for American states"
    }

  validates :zip,
    :format => {
      :allow_blank => true,
      :with => /^\d{5}(-\d{4})?$/,
      :if => :country_is_america?,
      :message => "is not a valid American zip code"
    }

  # AGA ID must be unique within each year
  validates :aga_id,
    :uniqueness => {
      :scope => :year,
      :allow_nil => true,
      :message => "id has already been taken"
    },
    :numericality => {
      :only_integer => true,
      :allow_nil => true,
      :message => "id is not a number"
    }

  # Attendee must always have a user.  We validate the presence of
  # the user, rather than the user_id, so that models can be
  # instantiated in any order.  When the models are saved, the
  # user should be saved first.
  validates_presence_of :user

  # Use MinorAgreementValidator (found in lib/) to require that understand_minor
  # be checked if the attendee will not be 18 before the first day of the Congress.
  validates :understand_minor, :minor_agreement => true

  # Validate that each user has exactly one primary attendee -Jared
  validates_uniqueness_of :is_primary, :scope => :user_id, :if => :is_primary?

  # Class Methods
  # =============

  # TODO: This doesn't belong in the ORM model.  It belongs in the
  # registration_process model.
  def self.assert_valid_page(p)
    raise "Invalid page: #{p}" unless Attendee.pages.include?(p.to_s)
  end

  def self.attribute_names_for_csv

    # Lisa wants the name and email in the first few columns
    # group together address, city, state, etc.
    first_attrs = %w[aga_id family_name given_name address_1 address_2 city state zip country phone]

    # we should move roommate request next to the plans
    last_attrs = %w[special_request roomate_request]

    attrs = self.attribute_names.delete_if { |x|
      first_attrs.index(x) ||
      last_attrs.index(x) ||
      internal_attributes.index(x)
    }

    # note: the order must match attendee_to_array() in reports_helper.rb
    return first_attrs.concat(attrs.concat(last_attrs))
  end

  def self.average_congresses year
    yr(year).average(:congresses_attended).try(:round, 1)
  end

  def self.internal_attributes
    # attrs rarely useful for display
    %w[id user_id understand_minor]
  end

  # `pages` returns an array of page names, in no particular order.
  # Not all pages are part of the registration process.
  def self.pages
    %w[admin basics events tournaments activities terminus wishes]
  end

  def self.with_planlessness planlessness
    case planlessness
    when :all then all
    when :planful then with_at_least_one_plan
    when :planless then planless
    else raise ArgumentError
    end
  end

  # Public Instance Methods
  # =======================

  # `age_in_years` Returns integer age in years on the start day of congress, not now.
  def age_in_years
    year_delta = congress_start.year - birth_date.year
    birthday_after_congress ? year_delta - 1 : year_delta
  end

  def anonymize string
    anonymous? ? 'Anonymous' : string
  end

  def attribute_value_for_csv atr
    return nil if self[atr].blank?
    if atr == 'rank'
      return get_rank_name
    elsif atr == 'tshirt_size'
      return get_tshirt_size_name
    else
      # In the past, I would encode entities using html_escape()
      # here, thinking that otherwise excel might not open the csv
      # correctly.  However, I can no longer reproduce this issue
      # with excel, so I'm no longer encoding entities. -Jared 2012-05-16
      return self[atr]
    end
  end

  def birthday_after_congress
    bday = Date.new(congress_start.year, birth_date.month, birth_date.day)
    (bday <=> congress_start) == 1
  end

  def get_family_name(respect_anonymity = false)
    name = NameInflector.capitalize_name(family_name)
    respect_anonymity ? anonymize(name) : name
  end

  def get_given_name(respect_anonymity = false)
    name = NameInflector.capitalize_name(given_name)
    respect_anonymity ? anonymize(name) : name
  end

  def clear_plan_category!(pc_id)
    attendee_plans.joins(:plan).where('plans.plan_category_id = ?', pc_id).destroy_all
  end

  def congress_start
    CONGRESS_START_DATE[self.year]
  end

  def anonymize_attribute atr
    anonymize self.send atr
  end

  def country_is_america?
    self.country == 'US'
  end

  def has_plans?
    plan_count > 0
  end

  def invoice_items
    items = []

    # How old will the attendee be on the first day of congress?
    atnd_age = self.age_in_years

    # Does this attendee qualify for any automatic discounts?
    Discount.yr(self.year).where("is_automatic = ?", true).each do |d|

      # To qualify for an automatic discount, the attendee must satisfy all criteria.
      satisfy_age_min = d.age_min.blank? || atnd_age >= d.age_min
      satisfy_age_max = d.age_max.blank? || atnd_age <= d.age_max
      satisfy_min_reg_date = d.min_reg_date.blank? || self.created_at.to_date <= d.min_reg_date.to_date

      if (satisfy_age_min && satisfy_age_max && satisfy_min_reg_date) then
        items << InvoiceItem.new(d.get_invoice_item_name, self.get_full_name, -1 * d.amount, 1)
      end

    end

    # Did this attendee claim any non-automatic discounts?
    # Optimization: Assuming discounts were eager-loaded, we can
    # avoid a query by using `select{}` instead of `where()`
    self.discounts.select{|d| !d.is_automatic?}.each do |d|
      items << InvoiceItem.new(d.get_invoice_item_name, self.get_full_name, -1 * d.amount, 1)
    end

    # Plans
    plans_to_invoice = attendee_plans.select{ |ap| ap.show_on_invoice? }
    items.concat plans_to_invoice.map{ |ap| ap.to_invoice_item(self.full_name) }

    # Activities
    self.activities.each do |e|
      if (e.price.present? && e.price > 0.0)
        items << InvoiceItem.new('Activity: ' + e.name, self.get_full_name, e.price, 1)
      end
    end

    return items
  end

  def invoice_total
    subtotals = invoice_items.map{|i| i.price * i.qty}
    subtotals.empty? ? 0 : subtotals.reduce(:+)
  end

  def minor?
    self.birth_date + 18.years > congress_start
  end

  def replace_all_activities activity_id_array
    activities.clear
    activities << Activity.yr(self.year).where(:id => activity_id_array)
  end

  def full_name(respect_anonymity = false)
    name = NameInflector.capitalize_name(given_name) + " " + NameInflector.capitalize_name(family_name)
    respect_anonymity ? anonymize(name) : name
  end

  # `get_full_name` is deprecated.  Please use full_name() instead.
  def get_full_name(respect_anonymity = false)
    full_name(respect_anonymity)
  end

  def full_name_possessive
    given_name + " " + family_name + ('s' == family_name[-1,1] ? "'" : "'s")
  end

  def name_and_rank
    get_full_name(false) + ", " + get_rank_name
  end

  def plan_count
    plans.count
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

  def plan_qty_hash
    ap_ordered = self.attendee_plans.order(:plan_id)
    ids = ap_ordered.map { |ap| ap.plan_id }
    qtys = ap_ordered.map { |ap| ap.quantity }
    Hash[ids.zip(qtys)]
  end

  def get_rank_name
    rank_name = ""
    RANKS.each { |r| if (r[1] == self.rank) then rank_name = r[0] end }
    if rank_name.empty? then raise "assertion failed: invalid rank" end
    return rank_name
  end

  def rank_name_for_badge
    rank == 0 ? "NP" : get_rank_name
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

private

  # Minors are required to have a guardian.  To safely invoke
  # minor?(), we must first check that birth_date is present.
  def require_guardian_full_name?
    birth_date.present? && minor?
  end

end
