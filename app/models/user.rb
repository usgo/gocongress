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
  attr_protected :is_admin, :job_ids
  
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
    sales = transactions.where(:trantype => 'S')
    sum = 0
    sales.each { |s| sum += s.amount }
    return sum
  end

  def balance
    get_invoice_total - amount_paid
  end

  def get_invoice_items
    invoice_items = []
    self.attendees.each { |a|
      item = {}
      item['item_description'] = 'Initial deposit'
      item['attendee_full_name'] = a.given_name + ' ' + a.family_name
      item['item_price'] = 75
      invoice_items.push item
    }
    return invoice_items
  end

  def get_invoice_total
    sum = 0
    self.get_invoice_items.each { |item| sum += item['item_price'] }
    return sum
  end

  def get_initial_deposit_due_date
    self.created_at.to_date + 1.month
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
