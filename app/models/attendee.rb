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
  has_many :minors, :class_name => "Attendee",
    :foreign_key => "guardian_attendee_id",
    :dependent => :restrict

  belongs_to :shirt

  # Mass assignment config
  # ----------------------

  attr_accessible :activity_ids, :aga_id, :anonymous,
    :airport_arrival, :airport_arrival_flight, :airport_departure,
    :birth_date, :country, :email, :family_name, :given_name, :gender,
    :guardian_attendee_id, :phone, :special_request, :rank,
    :roomate_request, :shirt_id, :tshirt_size, :understand_minor,
    :user_id, :will_play_in_us_open, :as => [:default, :admin]

  attr_accessible :comment, :minor_agreement_received, :as => :admin

  # Scopes
  # ------

  scope :not_anonymous, where(anonymous: false)

  # Using a subquery in the where clause is performant up to about
  # one thousand records.  -Jared 2012-05-13
  scope :with_at_least_one_plan, where("0 < (select count(*) from attendee_plans ap where ap.attendee_id = attendees.id)")
  scope :planless, where("0 = (select count(*) from attendee_plans ap where ap.attendee_id = attendees.id)")

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
  validates :minor_agreement_received, :inclusion => {:in => [true, false]}
  validates :rank,            :inclusion => {:in => Attendee::Rank::NUMERIC_RANK_LIST, :message => "is not valid"}, :presence => true
  validates :roomate_request, :length => {:maximum => 250}
  validates :special_request, :length => {:maximum => 250}
  validates :tshirt_size,     :inclusion => {:in => Shirt::SIZE_CODES, :message => " - Please select a size"}
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

  # Class Methods
  # =============

  def self.adults year
    where('birth_date < ?', CONGRESS_START_DATE[year.to_i] - 18.years)
  end

  def self.internal_attributes
    # attrs rarely useful for display
    %w[id shirt_id user_id understand_minor]
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

  def birthdate_in_congress_year
    Date.new(congress_start.year, birth_date.month, birth_date.day)
  end

  def birthday_after_congress?
    (birthdate_in_congress_year <=> congress_start) == 1
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

  def populate_atrs_for_new_form
    self.email = user.email
    ufac = user.first_atnd_created
    if ufac.present?
      ['country','phone'].each do |f|
        self[f] = ufac[f]
      end
    end
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

  def get_rank
    Attendee::Rank.new(self.rank)
  end

  def get_rank_name
    get_rank.name
  end

  def rank_name_for_badge
    rank == 0 ? "NP" : get_rank_name
  end

  def shirt_name
    shirt.try(:name)
  end

  def user_email
    user.try(:email)
  end

private

  # Minors are required to have a guardian.  To safely invoke
  # minor?(), we must first check that birth_date is present.
  def require_guardian?
    birth_date.present? && minor?
  end

end
