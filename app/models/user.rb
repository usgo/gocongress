require "invoice_item"

class User < ActiveRecord::Base
  include YearlyModel

  # Constants
  # ---------

  ROLES = [['Admin','A'], ['Staff','S'], ['User','U']]

  # In practice, we often load users based on the compound key (email,year).
  # For example, when authenticating or resetting a password.
  PRACTICAL_KEY = [:email,:year]

  # Devise modules: Do not use :validatable now that
  # the email uniqueness validation has a year scope
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         {:authentication_keys => PRACTICAL_KEY, :reset_password_keys => PRACTICAL_KEY}

  has_many :transactions, :dependent => :destroy

  # A user may register multiple attendees, eg. their family
  has_many :attendees, :dependent => :destroy

  # `primary_attendee` is deprecated
  has_one  :primary_attendee, :class_name => 'Attendee', :conditions => { :is_primary => true }

  # Validations
  # -----------

  validates_inclusion_of :role, :in => %w[A S U]

  validates :email,
    :presence => true,
    :uniqueness => { :scope => :year, :case_sensitive => false },
    :format => { :with => EMAIL_REGEX }

  validates :password,
    :presence => true,
    :length => {:minimum => 6},
    :confirmation => true,
    :if => :validate_password?

  # Mass-Assignment
  # ---------------
  #
  # Year is accessible, but we subclass RegistrationsController
  # to provide mass-assignment security

  attr_accessible :email, :password, :password_confirmation,
    :remember_me, :primary_attendee_attributes, :year

  # Scopes
  # ------

  scope :attendeeless, where("(select count(*) from attendees a where a.user_id = users.id) = 0")

  def self.email_range min, max
    where('lower(substr(email, 1, 1)) between ? and ?', min, max)
  end

  # Instance Methods
  # ----------------

  def admin?
    role == 'A'
  end

  def amount_paid
    sales_total = transactions.where(:trantype => 'S').sum(:amount)
    refund_total = transactions.where(:trantype => 'R').sum(:amount)
    return sales_total - refund_total
  end

  def attendee_invoice_items
    attendees.map {|a| a.invoice_items}.flatten
  end

  def balance
    get_invoice_total - amount_paid
  end

  def coalesce_full_name_then_email
    full_name || email
  end

  def comp_invoice_items
    transactions.comps.map {|t| t.to_invoice_item}
  end

  def first_atnd_created
    attendees.order('created_at desc').first
  end

  # As with all public instance methods, `full_name` must
  # gracefully handle the absence of the primary_attendee, now that
  # the presence of said association is no longer validated.
  def full_name
    primary_attendee.present? ? primary_attendee.full_name : nil
  end

  def full_name_possessive
    primary_attendee.present? ? primary_attendee.full_name_possessive : nil
  end

  def invoice_items
    attendee_invoice_items + comp_invoice_items
  end

  def get_invoice_total
    Invoice::Invoice.new(invoice_items).total
  end

  def staff?
    role == 'S'
  end

  def role_name
    ROLES.select{|r| r[1] == role}.first[0]
  end

  # Override the built-in devise method update_with_password()
  # so that we don't need current_password
  # Credit: Carlos Antonio da Silva
  def update_with_password(params={})
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end
    update_attributes(params)
  end

private

  # Password is validated when first creating the user record,
  # or if the password is being changed.
  def validate_password?
    new_record? || password.present? || password_confirmation.present?
  end

end
