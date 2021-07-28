require "invoice_item"

class Attendee < ApplicationRecord
  include YearlyModel

  # Attributes
  # ----------

  # The default of `receive_sms` is `false` because this and other phone-related
  # form fields are only shown for in-person years. In an online year, `false`
  # is the reasonable default.
  attribute :receive_sms, :boolean, default: false

  # Associations
  # ------------

  belongs_to :user

  has_many :attendee_plans, :dependent => :destroy
  has_many :plans, :through => :attendee_plans
  has_many :game_appointments

  has_many :attendee_activities, :dependent => :destroy
  has_many :activities, :through => :attendee_activities

  has_many :attendee_tournaments, :dependent => :destroy
  has_many :tournaments, :through => :attendee_tournaments

  belongs_to :guardian,
    class_name: "Attendee",
    foreign_key: "guardian_attendee_id",
    optional: true
  has_many :minors,
    class_name: "Attendee",
    foreign_key: "guardian_attendee_id",
    dependent: :restrict_with_exception

  belongs_to :shirt, optional: true

  # Validations
  # -----------

  validates :birth_date, presence: true
  validate :birth_date_is_modern
  validates :country,         :format => { :with => /\A[A-Z]{2}\z/ }, :presence => true
  validates :email,           :presence => true
  with_options(presence: { if: ->(atd) { atd.year_record.in_person? } }) do
    validates :emergency_name
    validates :emergency_phone
  end
  validates :family_name,     :presence => true
  validates :gender,          :inclusion => { :in => ["m", "f", "o"], :message => "is not valid" }, :presence => true
  validates :given_name,      :presence => true
  validates :guardian_full_name, :presence => { :if => :require_guardian_full_name? }
  validates :phone,
    if: ->(atd) { atd.receive_sms && atd.year_record&.in_person? },
    presence: true,
    phone: true
  validates :minor_agreement_received, :inclusion => { :in => [true, false] }
  validates :checked_in, :inclusion => { :in => [true, false] }
  validates :rank,
    inclusion: {
      in: Attendee::Rank::NUMERIC_RANK_LIST,
      message: "is not valid"
    },
    presence: true
  validates :receive_sms, :inclusion => {
    :in => [true, false], :message => ' - Please select yes or no'
  }
  validates :roomate_request, :length => { :maximum => 250 }
  validates :special_request, :length => { :maximum => 250 }
  validates :tshirt_size, :inclusion => { :in => Shirt::SIZE_CODES, :message => " - Please select a size", if: ->(atd) { atd.year_record.shirt } }
  validates_numericality_of :aga_id, :only_integer => true, :allow_nil => true, :message => "id is not a number"

  username_message = " - One of the tournaments you selected needs your %{attribute}."
  validates :username_kgs, :presence => { :if => Proc.new { |x| in_tournament?("kgs") }, :message => username_message }
  validates :username_igs, :presence => { :if => Proc.new { |x| in_tournament?("igs") }, :message => username_message }
  validates :username_ogs, :presence => { :if => Proc.new { |x| in_tournament?("ogs") }, :message => username_message }

  # Attendee must always have a user.  We validate the presence of
  # the user, rather than the user_id, so that models can be
  # instantiated in any order.  When the models are saved, the
  # user should be saved first.
  validates_presence_of :user

  # Scopes
  # =============
  scope :current_year, -> { where(year: Time.now.year) }

  # Class Methods
  # =============

  # Check to see if an attendee is signed up for a tournament that takes place
  # on a server, so that we can require the relevant username in that case
  def in_tournament?(server_name = nil)
    tournaments = Tournament.yr(year).where(:registration_sign_up => true).order('ordinal')
    selected_tournaments = tournaments.select { |t| self.tournament_ids.include? t.id }
    if server_name
      # If a server is specified, return whether the attendee has signed up for
      # any tournament on that server
      return selected_tournaments.any? { |t| t.server == server_name }
    else
      # If no server is specified, return whether the attendee has signed up for
      # any tournament at all
      return !selected_tournaments.empty?
    end
  end

  def self.adults(year)
    where('birth_date < ?', CONGRESS_START_DATE[year.to_i] - 18.years)
  end

  def self.attendee_cancelled
    where(cancelled: true)
  end

  def self.with_planlessness(planlessness)
    case planlessness
    when :all then all
    when :planful then with_at_least_one_plan
    when :planless then planless
    else raise ArgumentError
    end
  end

  def self.gather_aga_numbers
    aga_ids = []
    Attendee.current_year.find_each do |attendee|
      aga_ids.push(attendee.aga_id)
    end
    aga_ids.compact
  end

  # Using a subquery in the where clause is performant up to about
  # one thousand records.  -Jared 2012-05-13
  def self.with_at_least_one_plan
    where("cancelled = ? AND 0 < (select count(*) from attendee_plans ap where ap.attendee_id = attendees.id)", false)
  end

  def self.planless
    where("cancelled = ? OR 0 = (select count(*) from attendee_plans ap where ap.attendee_id = attendees.id)", true)
  end

  # Public Instance Methods
  # =======================

  def activities_as_invoice_items
    activities_with_prices.map { |a| a.to_invoice_item(full_name) }
  end

  def activities_with_prices
    activities.select { |a| a.price.present? && a.price > 0.0 }
  end

  def age
    Attendee::Age.new(birth_date, congress_start)
  end

  def age_in_years
    age.years
  end

  def anonymize(string)
    anonymous_or_underage? ? 'Anonymous' : string
  end

  def anonymous_or_underage?
    anonymous? || minor?
  end

  def attendee_alternate_name
    if alternate_name.present?
      ' (' + alternate_name + ')'
    else
      ''
    end
  end

  def family_name_anonymized
    anonymize NameInflector.capitalize family_name
  end

  def given_name_anonymized
    anonymize NameInflector.capitalize given_name
  end

  def clear_plans!
    attendee_plans.destroy_all
  end

  def congress_start
    CONGRESS_START_DATE[self.year]
  end

  def anonymize_attribute(atr)
    anonymize self.send atr
  end

  def guardian_name
    guardian.try :full_name
  end

  def has_plans?
    plan_count > 0
  end

  def has_plan?(plan)
    plans.include?(plan)
  end

  def invoice_items
    if cancelled?
      [InvoiceItem.new('Cancelled', full_name + attendee_alternate_name, 0, 0)]
    else
      plans_as_invoice_items + activities_as_invoice_items
    end
  end

  def invoice_total
    Invoice::Invoice.new(invoice_items).total
  end

  def minor?
    age.minor?
  end

  def full_name(respect_anonymity = false)
    name = NameInflector.capitalize(given_name) + " " + NameInflector.capitalize(family_name)
    respect_anonymity ? anonymize(name) : name
  end

  def formatted_email
    "\"#{self.full_name}\" <#{self.email}>"
  end

  def plan_count
    plans.count
  end

  def plan_selections
    attendee_plans.map(&:to_plan_selection)
  end

  def plans_as_invoice_items
    plans_to_invoice.map { |ap| ap.to_invoice_item(full_name, attendee_alternate_name) }
  end

  def plans_to_invoice
    attendee_plans.select { |ap| ap.show_on_invoice? }
  end

  def populate_atrs_for_new_form
    self.email = user.email
    ufac = user.first_atnd_created
    if ufac.present?
      ['country', 'phone'].each do |f|
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

  def rank_name
    get_rank.name
  end

  def shirt_name
    shirt.try(:name)
  end

  def user_email
    user.try(:email)
  end

  def user_paid_deposit
    user.try(:paid_deposit)
  end

  private

  def birth_date_is_modern
    if birth_date.present? && birth_date.year < 1900
      errors.add(:birth_date, 'cannot precede 1900')
    end
  end

  # Minors are required to have a guardian.  To safely invoke
  # minor?(), we must first check that birth_date is present.
  def require_guardian_full_name?
    birth_date.present? && minor?
  end
end
