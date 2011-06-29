require "invoice_item"

class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  # Specify a white list of model attributes that CAN be set via mass-assignment
  attr_accessible :email, :password, :password_confirmation, :remember_me, :primary_attendee_attributes

  # Specify a black list of model attributes that CAN'T be set via mass-assignment
  # On an unrelated note, I added a db-level default value of false for is_admin
  # -Jared 2010-12-30
  attr_protected :is_admin, :job_ids, :created_at, :updated_at

  # The following attributes come from Devise, AFAIK.
  # I'd like them to be attr_protected, but I'm not sure I can do that.
  # encrypted_password
  # password_salt
  # reset_password_token
  # remember_token
  # remember_created_at
  # sign_in_count
  # current_sign_in_at
  # last_sign_in_at
  # current_sign_in_ip
  # last_sign_in_ip

  has_many :transactions, :dependent => :destroy
  has_many :user_jobs, :dependent => :destroy
  has_many :jobs, :through => :user_jobs

  # A user may register multiple people, eg. their family
  # The primary attendee corresponds with the user themselves
  # TO DO: add is_admin condition to primary_attendee association
  has_one  :primary_attendee, :class_name => 'Attendee', :conditions => { :is_primary => true }
  has_many :attendees, :dependent => :destroy

  validates_uniqueness_of :email, :case_sensitive => false
  validates_inclusion_of :is_admin, :in => [true, false]

  # Email may not contain commas or single-quotes,
  # Because I do not want to escape them in JS
  validates_format_of :email, :with => /^[^',]*$/, :message => "may not contain commas or single-quotes"
  # Reset syntax highlighting for '

  # There must always be at least one attendee -Jared
  validates_presence_of :primary_attendee

  after_create :send_welcome_email

  # Set association attrs which cannot be set via mass assignment
  before_create :set_protected_attrs

  # Both User and Attendee have an email column, and we don't want to ask the
  # enduser to enter the same email twice when signing up -Jared 2010.12.31
  before_validation :apply_user_email_to_primary_attendee, :on => :create

  # Nested Attributes allow us to create forms for attributes of a parent
  # object and its associations in one go with fields_for()
  accepts_nested_attributes_for :primary_attendee

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

  def get_invoice_items
    invoice_items = []
    self.attendees.each do |a|
      invoice_items.concat a.invoice_items
    end

    # Comp transactions, eg. VIP discounts
    self.transactions.where(:trantype => 'C').each do |t|
      invoice_items.push InvoiceItem.inv_item_hash('Comp', 'N/A', -1 * t.amount, 1)
    end

    # Note: Refund transactions are NOT invoice items.  They should not
    # appear on the cost summary.  Instead, they should appear on the
    # ledger (payment history)

    return invoice_items
  end

  def get_invoice_total
    InvoiceItem.inv_item_total(self.get_invoice_items)
  end

  def get_initial_deposit_due_date
    self.created_at.to_date + 1.month
  end

  def get_num_attendee_deposits_paid
    num_atnd_paid = 0
    self.attendees.each { |a| num_atnd_paid += 1 if a.deposit_received_at.present? }
    return num_atnd_paid
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

  def set_protected_attrs
    # The primary_attendee attribute is_primary must be attr_protected. However,
    # the devise registration controller will (of course) not know to set
    # is_primary. So, we must set it manually.  Note that mass assignment of
    # is_primary will still be attempted, causing a warning. -Jared 2011.1.30
    primary_attendee.is_primary = true
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
