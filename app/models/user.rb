class User < ActiveRecord::Base

	# Include default devise modules. Others available are:
	# :token_authenticatable, :confirmable, :lockable and :timeoutable
	devise :database_authenticatable, :registerable,
				 :recoverable, :rememberable, :trackable, :validatable
	
	# Specify a white list of model attributes that can be set via mass-assignment
	attr_accessible :email, :password, :password_confirmation, :remember_me, :full_name, :is_admin, :job_ids
	
	validates_presence_of :full_name
	validates_inclusion_of :is_admin, :in => [true, false]
		
	has_many :user_jobs
	has_many :jobs, :through => :user_jobs

end
