class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  # Specify a white list of model attributes that CAN be set via mass-assignment
  attr_accessible :email, :password, :password_confirmation, :remember_me, :job_ids, :primary_attendee_attributes

  # Specify a black list of model attributes that CAN'T be set via mass-assignment
  # On an unrelated note, I added a db-level default value of false for is_admin
  # -Jared 2010-12-30
  attr_protected :is_admin
    
  has_many :user_jobs, :dependent => :destroy
  has_many :jobs, :through => :user_jobs

  # A user may register multiple people, eg. their family
  # The primary attendee corresponds with the user themselves
  belongs_to  :primary_attendee, :class_name => 'Attendee'
  has_many :attendees, :dependent => :destroy

  validates_uniqueness_of :email
  validates_inclusion_of :is_admin, :in => [true, false]

  # There must always be at least one attendee -Jared
  validates_presence_of :primary_attendee

  after_create :send_welcome_email

  # Both User and Attendee have an email column, and we don't want to ask the
  # enduser to enter the same email twice when signing up -Jared 2010.12.31
  before_validation :apply_user_email_to_primary_attendee, :on => :create

  # For some reason, primary attendee was not getting a user_id! -Jared 2011.1.2
  after_create :apply_user_id_to_primary_attendee

  # Nested Attributes allow us to create forms for attributes of a parent
  # object and its associations in one go with fields_for()
  accepts_nested_attributes_for :primary_attendee

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

  def apply_user_id_to_primary_attendee
    if primary_attendee.present?
      primary_attendee.user_id = self.id
    end
  end

protected

  def password_required?
    !persisted? || password.present? || password_confirmation.present?
  end

end
