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
  has_many :user_jobs, :dependent => :destroy
  has_many :jobs, :through => :user_jobs

  # A user may register multiple people, eg. their family
  # The primary attendee corresponds with the user themselves
  has_one  :primary_attendee, :class_name => 'Attendee', :conditions => { :is_primary => true }
  has_many :attendees, :dependent => :destroy

  ROLES = [['Admin','A'], ['Staff','S'], ['User','U']]
  validates_inclusion_of :role, :in => %w[A S U]

  # Email must be unique within each year and may not contain commas or
  # single-quotes because I do not want to escape them in JS
  validates :email, \
    :presence => true, \
    :uniqueness => { :scope => :year, :case_sensitive => false }, \
    :format => { :with => /^[^',]*$/, :message => "may not contain commas or quotes" }

  after_create :send_welcome_email

  # Both User and Attendee have an email column, and we don't want to ask the
  # enduser to enter the same email twice when signing up -Jared 2010.12.31
  before_validation :apply_user_email_to_primary_attendee, :on => :create

  # Nested Attributes allow us to create forms for attributes of a parent
  # object and its associations in one go with fields_for()
  accepts_nested_attributes_for :primary_attendee

  # After signing in, go to the "My Account" page, unless the primary
  # attendee has not filled out the registration form yet (for example,
  # immediately after submitting the devise registration form)
  def after_sign_in_path
    if primary_attendee.present?
      pa = primary_attendee
      pa.has_plans? ? pa.my_account_path : pa.next_page(:basics, nil, [])
    else
      Rails.application.routes.url_helpers.add_attendee_to_user_path(self.year, self)
    end
  end

  def amount_paid
    sum = 0
    sales = transactions.where(:trantype => 'S')
    sales.each { |s| sum += s.amount }
    refunds = transactions.where(:trantype => 'R')
    refunds.each { |r| sum -= r.amount }
    return sum
  end

  def balance
    get_invoice_total - amount_paid
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

  def is_admin?
    role == 'A'
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
