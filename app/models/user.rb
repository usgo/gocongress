require "invoice_item"

class User < ActiveRecord::Base
  include YearlyModel

  # In practice, we often load users based on the compound key (email,year).
  # For example, when authenticating or resetting a password.
  PRACTICAL_KEY = [:email,:year]

  # Devise modules: Do not use :validatable now that
  # the email uniqueness validation has a year scope
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         {:authentication_keys => PRACTICAL_KEY, :reset_password_keys => PRACTICAL_KEY}

  attr_accessible :email, :password, :password_confirmation,
    :remember_me, :primary_attendee_attributes

  # Year is accessible, but we subclass RegistrationsController
  # to provide mass-assignment security
  attr_accessible :year

  has_many :transactions, :dependent => :destroy

  # A user may register multiple people, eg. their family
  # The primary attendee corresponds with the user themselves
  # (Assuming everyone registers themselves first)
  has_one  :primary_attendee, :class_name => 'Attendee', :conditions => { :is_primary => true }
  has_many :attendees, :dependent => :destroy

  ROLES = [['Admin','A'], ['Staff','S'], ['User','U']]
  validates_inclusion_of :role, :in => %w[A S U]

  # Validate email address according to html5 spec (http://bit.ly/nOR1B6)
  # but slightly stricter (no single quotes, backticks, slashes, or dollar signs)
  validates :email, \
    :presence => true, \
    :uniqueness => { :scope => :year, :case_sensitive => false }, \
    :format => { :with => EMAIL_REGEX }

  after_create :send_welcome_email

  # Both User and Attendee have an email column, and we don't want to ask the
  # enduser to enter the same email twice when signing up -Jared 2010.12.31
  before_validation :apply_user_email_to_primary_attendee, :on => :create

  # Constants
  # ---------

  # When generating invoices for multiple users, passing this
  # constant into includes() can really speed things up.
  EAGER_LOAD_CONFIG_FOR_INVOICES = [
    :primary_attendee,
    {
      :attendees => [
        {:attendee_activities => :activity},
        {:attendee_discounts => :discount},
        {:attendee_plans => :plan}
      ]
    }
  ]

  # Scopes
  # ------

  scope :attendeeless, where("(select count(*) from attendees a where a.user_id = users.id) = 0")

  def self.pri_att_fam_name_range min, max
    joins(:primary_attendee) \
      .where('lower(substr(family_name,1,1)) between ? and ?', min, max)
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

  def balance
    get_invoice_total - amount_paid
  end

  def coalesce_full_name_then_email
    full_name || email
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

  def get_invoice_items
    invoice_items = []
    self.attendees.each do |a|
      invoice_items.concat a.invoice_items
    end

    # Comp transactions, eg. VIP discounts
    self.transactions.where(:trantype => 'C').each do |t|
      invoice_items << InvoiceItem.new(t.description, 'N/A', -1 * t.amount, 1)
    end

    # Note: Refund transactions are NOT invoice items.  They should not
    # appear on the cost summary.  Instead, they should appear on the
    # ledger (payment history)

    return invoice_items
  end

  def get_invoice_total
    subtotals = get_invoice_items.map{|i| i.price * i.qty}
    subtotals.empty? ? 0 : subtotals.reduce(:+)
  end

  # `is_admin?` is deprecated.  Please use `admin?`
  def is_admin?
    admin?
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

  # make sure you:
  # export GMAIL_SMTP_USER=username@gmail.com
  # export GMAIL_SMTP_PASSWORD=yourpassword
  # for heroku, use: heroku config:add GMAIL_SMTP_USER=username@gmail.com
  # see /vendor/plugins/gmail_smtp/lib/actionmailer_gmail.rb
  # -Jared 2010.12.27
  def send_welcome_email
    UserMailer.welcome_email(self).deliver
  end

  def apply_user_email_to_primary_attendee
    # If primary_attendee isn't here, I don't want a NoMethodError
    # Instead, I'd rather get a RecordNotValid
    if primary_attendee.present?
      primary_attendee.email = self.email
    end
  end

protected

  def password_required?
    !persisted? || password.present? || password_confirmation.present?
  end

end
