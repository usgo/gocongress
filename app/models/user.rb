require 'digest/sha1'

class User < ActiveRecord::Base

validates_presence_of :full_name
validates_presence_of :email
validates_uniqueness_of :email

attr_accessor :password_confirmation
validates_confirmation_of :password

validate :validate_password_is_not_blank

has_many :user_jobs
has_many :jobs, :through => :user_jobs

def self.authenticate(email, password)
	user = self.find_by_email(email)
	if user
		expected_password = encrypted_password(password, user.salt)
		if user.hashed_password != expected_password
			user = nil
		end
	end
	user
end

# 'password' is a virtual attribute
def password
	@password
end

def password=(pwd)
	@password = pwd
	return if pwd.blank?
	create_new_salt
	self.hashed_password = User.encrypted_password(self.password, self.salt)
end

private

	def create_new_salt
		self.salt = self.object_id.to_s + rand.to_s
	end

	def self.encrypted_password(password, salt)
		string_to_hash = password + "foobar" + salt
		Digest::SHA1.hexdigest(string_to_hash)
	end

	def validate_password_is_not_blank
		errors.add(:password, "Missing password") if hashed_password.blank?
	end

end
