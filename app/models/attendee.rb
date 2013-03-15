require "invoice_item"

class Attendee < ActiveRecord::Base
  include YearlyModel

  # Associations
  # ------------

  belongs_to :user

  has_many :attendee_plans, :dependent => :destroy
  has_many :plans, :through => :attendee_plans

  has_many :attendee_activities, :dependent => :destroy
  has_many :activities, :through => :attendee_activities

  belongs_to :guardian, :class_name => "Attendee",
    :foreign_key => "guardian_attendee_id"

  belongs_to :shirt_color

  # Mass assignment config
  # ----------------------

  attr_accessible :activity_ids, :aga_id, :anonymous, :airport_arrival,
    :airport_arrival_flight, :airport_departure, :birth_date,
    :country, :email, :family_name,
    :given_name, :gender, :guardian_attendee_id,
    :phone, :special_request, :rank,
    :roomate_request, :tshirt_size, :understand_minor, :user_id,
    :will_play_in_us_open,
    :as => [:default, :admin]

  attr_accessible :comment, :minor_agreement_received, :as => :admin

  # Constants
  # ---------

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

  scope :pro, where(:rank => 101..109)
  scope :dan, where(:rank => 1..9)
  scope :kyu, where(:rank => -30..-1)

  scope :not_anonymous, where(anonymous: false)

  # Some "blank" birth_date values have made it into production. The following
  # scope is a useful way to filter out those records when querying birth_date
  # (eg. finding youngest attendee) -Jared 2011-02-07
  scope :reasonable_birth_date, where("birth_date > ? AND birth_date < ?", '1880-01-01', Time.now())

  # Using a subquery in the where clause is performant up to about
  # one thousand records.  -Jared 2012-05-13
  scope :with_at_least_one_plan, where("0 < (select count(*) from attendee_plans ap where ap.attendee_id = attendees.id)")
  scope :planless, where("0 = (select count(*) from attendee_plans ap where ap.attendee_id = attendees.id)")

  scope :has_plan_in_event, lambda { |event|
    where("
      exists (
        select *
        from attendee_plans ap
        inner join plans p on p.id = ap.plan_id
        inner join plan_categories pc on pc.id = p.plan_category_id
        where ap.attendee_id = attendees.id
          and pc.event_id = ?
      )",
    event.id)
  }

  # Validations
  # -----------

  validates :birth_date,      :presence => true
  validates_date :birth_date, :after => Date.civil(1900,1,1), :allow_blank => false
  validates :country,         :format => {:with => /^[A-Z]{2}$/}, :presence => true
  validates :email,           :presence => true
  validates :family_name,     :presence => true
  validates :gender,          :inclusion => {:in => ["m","f"], :message => "is not valid"}, :presence => true
  validates :given_name,      :presence => true
  validates :guardian,        :presence => { :if => :require_guardian? }
  validates :is_primary,      :inclusion => {:in => [true, false]}
  validates :minor_agreement_received, :inclusion => {:in => [true, false]}
  validates :rank,            :inclusion => {:in => Attendee::Rank::NUMERIC_RANK_LIST, :message => "is not valid"}, :presence => true
  validates :roomate_request, :length => {:maximum => 250}
  validates :special_request, :length => {:maximum => 250}
  validates :tshirt_size,     :inclusion => {:in => TSHIRT_SIZE_LIST, :message => " - Please select a size"}
  validates :will_play_in_us_open, :inclusion => {
    :in => [true, false], :message => ' - Please select yes or no'}

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

  def self.adults year
    where('birth_date < ?', CONGRESS_START_DATE[year.to_i] - 18.years)
  end

  def self.attribute_names_for_csv

    # Lisa wants the name and email in the first few columns
    first_attrs = %w[aga_id family_name given_name country phone]

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

  def self.internal_attributes
    # attrs rarely useful for display
    %w[id user_id understand_minor]
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

  def activities_as_invoice_items
    activities_with_prices.map { |a| a.to_invoice_item(full_name) }
  end

  def activities_with_prices
    activities.select { |a| a.price.present? && a.price > 0.0 }
  end

  # `age_in_years` Returns integer age in years on the start day of congress, not now.
  def age_in_years
    raise 'birth date undefined' if birth_date.nil?
    year_delta = congress_start.year - birth_date.year
    birthday_after_congress? ? year_delta - 1 : year_delta
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

  def birthday_after_congress?
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

  def clear_plans!
    attendee_plans.destroy_all
  end

  def congress_start
    CONGRESS_START_DATE[self.year]
  end

  def anonymize_attribute atr
    anonymize self.send atr
  end

  def has_plans?
    plan_count > 0
  end

  def has_plan? plan
    plans.include?(plan)
  end

  def invoice_items
    plans_as_invoice_items + activities_as_invoice_items
  end

  def invoice_total
    Invoice::Invoice.new(invoice_items).total
  end

  def minor?
    self.birth_date + 18.years > congress_start
  end

  def full_name(respect_anonymity = false)
    name = NameInflector.capitalize_name(given_name) + " " + NameInflector.capitalize_name(family_name)
    respect_anonymity ? anonymize(name) : name
  end

  def full_name_possessive
    given_name + " " + family_name + ('s' == family_name[-1,1] ? "'" : "'s")
  end

  def name_and_rank
    full_name(false) + ", " + get_rank_name
  end

  def plan_count
    plans.count
  end

  def plan_selections
    attendee_plans.map(&:to_plan_selection)
  end

  def plans_as_invoice_items
    plans_to_invoice.map{ |ap| ap.to_invoice_item(full_name) }
  end

  def plans_to_invoice
    attendee_plans.select{ |ap| ap.show_on_invoice? }
  end

  def possessive_pronoun_or_name
    is_primary? ? "My" : full_name_possessive
  end

  def objective_pronoun_or_name_and_copula
    is_primary? ? "You are" : full_name + " is"
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
    Attendee::Rank.new(self.rank).name
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

private

  # Minors are required to have a guardian.  To safely invoke
  # minor?(), we must first check that birth_date is present.
  def require_guardian?
    birth_date.present? && minor?
  end

end
