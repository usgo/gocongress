class User < ActiveRecord::Base

	# Include default devise modules. Others available are:
	# :token_authenticatable, :confirmable, :lockable and :timeoutable
	devise :database_authenticatable, :registerable,
				 :recoverable, :rememberable, :trackable, :validatable
	
	# Specify a white list of model attributes that can be set via mass-assignment
	attr_accessible :email, :password, :password_confirmation, :remember_me, :full_name, :is_admin, :job_ids, :primary_attendee_attributes
	
	validates_presence_of :full_name
	validates_inclusion_of :is_admin, :in => [true, false]
		
	has_many :user_jobs
	has_many :jobs, :through => :user_jobs

	# A user may register multiple people, eg. their family
	# The primary attendee corresponds with the user themselves
  has_one  :primary_attendee, :class_name => 'Attendee'
  has_many :attendees, :dependent => :destroy

	after_create :send_welcome_email

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

protected

	def password_required?
		!persisted? || password.present? || password_confirmation.present?
	end

end
