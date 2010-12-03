class User < ActiveRecord::Base

has_many :user_jobs
has_many :jobs, :through => :user_jobs

end
